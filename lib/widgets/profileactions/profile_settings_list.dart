import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/pages/language_selection_page.dart';
import 'package:freeway_app/providers/language_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
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
              title: Text('Habilitar $biometricType'),
              content: Text(
                  'Al habilitar $biometricType, podrás acceder a la aplicación de forma más rápida y segura. '
                  '¿Deseas continuar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continuar'),
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
              title: 'Password',
              icon: Icons.lock_outline,
              onTap: () {
                // TODO: Implementar navegación
              },
            ),
            const ProfileDivider(),
            Consumer<BiometricProvider>(
              builder: (context, biometricProvider, child) {
                // Si está cargando o no está disponible, mostrar un widget diferente
                if (biometricProvider.isLoading) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Center(child: LoadingView(message: 'Loading...')),
                  );
                }

                if (!biometricProvider.isAvailable) {
                  return ProfileSettingsItem(
                    title: 'Biometric not available',
                    subtitle:
                        'Your device does not support biometric authentication.',
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No se pudo habilitar ${biometricProvider.biometricType}',
                          ),
                        ),
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
              title: 'App information',
              icon: Icons.info_outline,
              onTap: () {
                // TODO: Implementar navegación
              },
            ),
            const ProfileDivider(),
            ProfileSettingsSwitch(
              title: 'Enable push notifications',
              icon: Icons.notifications_none,
              value: true,
              onChanged: (value) {
                // TODO: Implementar cambio de notificaciones
              },
            ),
            const ProfileDivider(),
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
