import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyCheckCard extends StatelessWidget {
  final VoidCallback onSafetyConfirmed;

  const SafetyCheckCard({
    required this.onSafetyConfirmed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getBoxShadowColor(context),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              context.translate('submitClaim.safetyCheck.title'),
              style: TextStyle(
                color: AppTheme.getPrimaryColor(context),
                fontSize: responsiveFontSizes.titleLarge(context),
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.translate('submitClaim.safetyCheck.helpMessage'),
            style: TextStyle(
              color: AppTheme.getSubtitleTextColor(context),
              fontSize: responsiveFontSizes.bodyLarge(context),
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Crear la URI para abrir la aplicación de llamadas con el 911
                      final Uri launchUri = Uri.parse('tel:911');

                      // Abrir la aplicación de llamadas
                      await launchUrl(
                        launchUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      // Mostrar un mensaje de error si no se puede abrir la aplicación de llamadas
                      if (!context.mounted) return;
                      showAppSnackBar(
                        context,
                        context.translate('common.errorOpeningPhone'),
                        const Duration(seconds: 2),
                        backgroundColor: AppTheme.getRedColor(context),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getBackgroundOrangeColor(context),
                    foregroundColor: AppTheme.getOrangeColor(context),
                    side: BorderSide(color: AppTheme.getOrangeColor(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    context.translate('submitClaim.safetyCheck.call911'),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.bodyMedium(context),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: ElevatedButton(
                  onPressed: onSafetyConfirmed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    context.translate('submitClaim.safetyCheck.imSafe'),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.bodyMedium(context),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
