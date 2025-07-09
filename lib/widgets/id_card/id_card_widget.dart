import 'package:flutter/material.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:intl/intl.dart';

class IdCardWidget extends StatelessWidget {
  final User user;
  final PolicyModel policy;
  final double width;

  const IdCardWidget({
    required this.user,
    required this.policy,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Usar el número de póliza de la política
    final displayPolicyNumber = policy.policyNumber;

    // Formatear fechas desde los strings de la política
    final dateFormat = DateFormat('MM/dd/yyyy');
    final DateTime? effectiveDate = _parseDate(policy.effectiveDate);
    final DateTime? expirationDate = _parseDate(policy.expirationDate);

    final effectiveDateStr =
        effectiveDate != null ? dateFormat.format(effectiveDate) : '--/--/----';
    final expirationDateStr = expirationDate != null
        ? dateFormat.format(expirationDate)
        : '--/--/----';
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getBoxShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header azul con logo
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context), // Color azul de Freeway
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/home/idcardicons/freeway_logo_white.png',
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Freeway Insurance',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: responsiveFontSizes.titleMedium(context),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido de la tarjeta
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de información del asegurado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Named Insured
                      Text(
                        context.translate('idCard.namedInsured'),
                        style: TextStyle(
                          fontSize: responsiveFontSizes.labelLarge(context),
                          color: AppTheme.getTextGreyColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nombre del asegurado
                      Text(
                        policy.insuredName,
                        style: TextStyle(
                          fontSize: responsiveFontSizes.titleMedium(context),
                          color: AppTheme.getPrimaryColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Fila con la información de la aseguradora y número de póliza
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Carrier
                      SizedBox(
                        width: screenWidth * 0.35,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('idCard.carrier'),
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getTextGreyColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Usar FittedBox para adaptar el texto al espacio disponible
                            Text(
                              policy.carrierName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Policy Number
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('idCard.policyNumberLabel'),
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getTextGreyColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Usar FittedBox para adaptar el número de póliza al espacio disponible
                            Text(
                              displayPolicyNumber,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Fila con estado, fecha efectiva y fecha de expiración
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // State
                      SizedBox(
                        width: screenWidth * 0.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('idCard.state'),
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getTextGreyColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.state,
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Effective Date
                      SizedBox(
                        width: screenWidth * 0.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('idCard.effectiveDate'),
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getTextGreyColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              effectiveDateStr,
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expiration Date
                      SizedBox(
                        width: screenWidth * 0.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('idCard.expirationDate'),
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getTextGreyColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expirationDateStr,
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer con código de barras
          Container(
            height: screenWidth * 0.2,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Image.asset(
                'assets/home/idcardicons/barcode.png',
                width: screenWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para parsear fechas desde strings
  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
