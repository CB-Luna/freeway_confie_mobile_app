import 'package:acceptance_app/data/models/auth/policy_model.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/policy_logo_utils.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomClaimCard extends StatelessWidget {
  final PolicyModel? policy;

  const CustomClaimCard({
    this.policy,
    super.key,
  });

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    await launchUrl(phoneUri);
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Obtener información de la póliza
    final String insuranceCompany = policy?.carrierName ?? 'Freeway Insurance';
    final String? claimPhone =
        policy?.carrierClaimPhone == '' ? null : policy?.carrierClaimPhone;
    final String? claimUrl =
        policy?.carrierClaimUrl == '' ? null : policy?.carrierClaimUrl;
    final String? logoUrl = policy?.carrierLogoUrl;

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
        children: [
          // Logo de la aseguradora
          SizedBox(
            height: width * 0.15,
            child: PolicyLogoUtils.getPolicyLogo(
              context,
              logoUrl,
              height: width * 0.1,
            ),
          ),
          const SizedBox(height: 16),
          // Nombre de la aseguradora
          Text(
            insuranceCompany,
            style: TextStyle(
              color: AppTheme.getPrimaryColor(context),
              fontSize: responsiveFontSizes.titleSmall(context),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Mensaje principal
          Text(
            context
                .translate('submitClaim.customClaim.reportDirectlyTo')
                .replaceAll('{0}', insuranceCompany),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.getTitleTextColor(context),
              fontSize: responsiveFontSizes.bodyMedium(context),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 24),

          // Mostrar información de contacto según disponibilidad
          if (claimPhone != null && claimUrl == null)
            // Solo teléfono disponible
            Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${context.translate('submitClaim.customClaim.pleaseCall')} ',
                        style: TextStyle(
                          color: AppTheme.getTextGreyColor(context),
                          fontSize: responsiveFontSizes.bodyMedium(context),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      WidgetSpan(
                        child: Text(
                          claimPhone,
                          style: TextStyle(
                            color: AppTheme.getPrimaryColor(context),
                            fontSize: responsiveFontSizes.bodyMedium(context),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextSpan(
                        text:
                            ' ${context.translate('submitClaim.customClaim.toReportClaim')}',
                        style: TextStyle(
                          color: AppTheme.getTextGreyColor(context),
                          fontSize: responsiveFontSizes.bodyMedium(context),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _launchPhone(claimPhone);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getPrimaryColor(context),
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      context.translateWithArgs(
                        'submitClaim.customClaim.callNumber',
                        args: [claimPhone],
                      ),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.bodyLarge(context),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (claimPhone == null && claimUrl != null)
            // Solo URL disponible
            Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${context.translate('submitClaim.customClaim.pleaseVisit')} ',
                        style: TextStyle(
                          color: AppTheme.getTextGreyColor(context),
                          fontSize: responsiveFontSizes.bodyMedium(context),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Abrir URL de reclamaciones si está disponible
                      _launchUrl(claimUrl);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getPrimaryColor(context),
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      context.translate('submitClaim.bluefireClaim.startClaim'),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.bodyLarge(context),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (claimPhone != null && claimUrl != null)
            Column(
              children: [
                Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${context.translate('submitClaim.customClaim.pleaseCall')} ',
                            style: TextStyle(
                              color: AppTheme.getTextGreyColor(context),
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          WidgetSpan(
                            child: Text(
                              claimPhone,
                              style: TextStyle(
                                color: AppTheme.getPrimaryColor(context),
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${context.translate('submitClaim.customClaim.toReportClaim')}',
                            style: TextStyle(
                              color: AppTheme.getTextGreyColor(context),
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _launchPhone(claimPhone);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(context),
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          context.translateWithArgs(
                            'submitClaim.customClaim.callNumber',
                            args: [claimPhone],
                          ),
                          style: TextStyle(
                            fontSize: responsiveFontSizes.bodyLarge(context),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${context.translate('submitClaim.customClaim.orVisit')} ',
                            style: TextStyle(
                              color: AppTheme.getTextGreyColor(context),
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Abrir URL de reclamaciones si está disponible
                          _launchUrl(claimUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(context),
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          context.translate(
                            'submitClaim.bluefireClaim.startClaim',
                          ),
                          style: TextStyle(
                            fontSize: responsiveFontSizes.bodyLarge(context),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
