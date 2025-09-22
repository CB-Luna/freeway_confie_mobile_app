import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/pages/app_info_page.dart';
import 'package:freeway_app/pages/language_selection_page.dart';
import 'package:freeway_app/pages/password_change_page.dart';
import 'package:freeway_app/pages/user_data_page.dart';
import 'package:freeway_app/providers/language_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../providers/biometric_provider.dart';
import 'profile_divider.dart';
import 'profile_logout.dart';
import 'profile_settings_item.dart';
import 'profile_settings_switch.dart';

class ProfileSettingsList extends StatelessWidget {
  const ProfileSettingsList({super.key});

  /// Muestra un diálogo de confirmación para habilitar la biometría
  Future<bool> _showBiometricConfirmationDialog(
    BuildContext context,
    String biometricType,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                context.translateWithArgs(
                  'profile.biometricEnable',
                  args: [biometricType],
                ),
                style: TextStyle(
                  fontSize: responsiveFontSizes.titleMedium(context),
                ),
              ),
              content: Text(
                context.translateWithArgs(
                  'profile.biometricMessage',
                  args: [biometricType],
                ),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    context.translate('profile.cancel'),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.bodyMedium(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    context.translate('profile.confirm'),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.bodyMedium(context),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border.all(
          width: 1,
          color: AppTheme.getDetailsGreyColor(context),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height -
              150, // Altura fija considerando el header
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            ProfileSettingsItem(
              title: context.translate('profile.dataUser'),
              icon: Icons.person_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserDataPage(),
                  ),
                );
              },
            ),
            const ProfileDivider(),
            ProfileSettingsItem(
              title: context.translate('profile.password'),
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordChangePage(),
                  ),
                );
              },
            ),
            const ProfileDivider(),
            // Biometría
            Consumer<BiometricProvider>(
              builder: (context, biometricProvider, child) {
                // Establecer el contexto para las traducciones
                biometricProvider.setContext(context);

                // Si está cargando o no está disponible, mostrar un widget diferente
                if (biometricProvider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: Center(
                      child: LoadingView(
                        message: context.translate('profile.loading'),
                      ),
                    ),
                  );
                }

                if (!biometricProvider.isAvailable) {
                  return ProfileSettingsItem(
                    title: context.translate('profile.biometricNotAvailable'),
                    subtitle: context
                        .translate('profile.biometricNotAvailableMessage'),
                    icon: Icons.fingerprint_outlined,
                    onTap: () {},
                    enabled: false,
                  );
                }

                return ProfileSettingsSwitch(
                  title: biometricProvider.biometricType,
                  icon: biometricProvider.biometricType.contains('Face')
                      ? Icons.face_outlined
                      : Icons.fingerprint,
                  value: biometricProvider.isEnabled,
                  onChanged: (value) async {
                    // Mostrar un diálogo de confirmación
                    if (value) {
                      final confirmed = await _showBiometricConfirmationDialog(
                        context,
                        biometricProvider.biometricType,
                      );
                      if (!confirmed) return;
                    }

                    // Intentar habilitar/deshabilitar la biometría
                    final success =
                        await biometricProvider.toggleBiometric(value);

                    if (!success && value && context.mounted) {
                      // Si falló al habilitar, mostrar un mensaje
                      if (!context.mounted) return;
                      showAppSnackBar(
                        context,
                        context.translateWithArgs(
                          'profile.biometricEnableFailed',
                          args: [biometricProvider.biometricType],
                        ),
                        const Duration(seconds: 2),
                        backgroundColor: AppTheme.getRedColor(context),
                      );
                    }
                  },
                );
              },
            ),
            const ProfileDivider(),
            ProfileSettingsItem(
              title: context.translate('profile.languages'),
              icon: Icons.language,
              subtitle: Provider.of<LanguageProvider>(context)
                  .getCurrentLanguageName(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionPage(),
                  ),
                );
              },
            ),
            const ProfileDivider(),
            ProfileSettingsItem(
              title: context.translate('profile.appInfo'),
              icon: Icons.info_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppInfoPage(),
                  ),
                );
              },
            ),
            const ProfileDivider(),
            // TODO: Implementar cambio de notificaciones
            // ProfileSettingsSwitch(
            //   title: context.translate('profile.notifications'),
            //   icon: Icons.notifications_none,
            //   value: true,
            //   onChanged: (value) {
            //
            //   },
            // ),
            // const ProfileDivider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: ProfileLogoutButton(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
