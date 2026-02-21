import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/phone_call_helper.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

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
                    // Usar el helper para llamadas de emergencia
                    await PhoneCallHelper.makeEmergencyCall(context);
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
