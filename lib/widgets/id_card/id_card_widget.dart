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
        border: Border.all(
          color: AppTheme.getBoxShadowColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header con logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Row(
              children: [
                Image.asset(
                  'assets/home/idcardicons/freeway_logo_white.png',
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Freeway Insurance',
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: responsiveFontSizes.titleMedium(context),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Texto de aviso legal en la parte superior
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              context.translate('idCard.notProofOfCoverage').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.black,
                fontSize: responsiveFontSizes.bodyMedium(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del asegurado (en tamaño grande)
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: TextStyle(
                    fontSize: responsiveFontSizes.titleMedium(context),
                    color: AppTheme.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Fila con información de la aseguradora y estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrier
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('idCard.carrier'),
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodySmall(context),
                              color: AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            policy.carrierName,
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              color: AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // State
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.translate('idCard.state'),
                          style: TextStyle(
                            fontSize: responsiveFontSizes.bodySmall(context),
                            color: AppTheme.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.state,
                          style: TextStyle(
                            fontSize: responsiveFontSizes.bodyMedium(context),
                            color: AppTheme.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Línea divisoria
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 10),

                // Fila con fechas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Effective Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('idCard.effectiveDate'),
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodySmall(context),
                              color: AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            effectiveDateStr,
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              color: AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expiration Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.translate('idCard.expirationDate'),
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodySmall(context),
                              color: AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expirationDateStr,
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              color: AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Número de póliza
                Center(
                  child: Column(
                    children: [
                      Text(
                        context.translate('idCard.policyNumberLabel'),
                        style: TextStyle(
                          fontSize: responsiveFontSizes.bodySmall(context),
                          color: AppTheme.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayPolicyNumber,
                        style: TextStyle(
                          fontSize: responsiveFontSizes.bodyMedium(context),
                          color: AppTheme.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Imagen de footer
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Image.asset(
                    'assets/footer_image.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
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
