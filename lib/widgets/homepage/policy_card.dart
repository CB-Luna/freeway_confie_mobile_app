import 'package:flutter/material.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/pages/id_card_page.dart';
import 'package:freeway_app/pages/webview_page.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:intl/intl.dart';

import '../../data/models/home_policy/vehicle.dart';
import '../../widgets/theme/app_theme.dart';

class PolicyCard extends StatefulWidget {
  final User user;
  final Vehicle? vehicle;

  const PolicyCard({
    required this.user,
    super.key,
    this.vehicle,
  });

  @override
  State<PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<PolicyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    // Configurar la animación del shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String plateNumber = widget.vehicle?.plate ?? 'POLICY-1';
    final bool isActive = widget.vehicle?.status ?? true;
    final String rawNextPaymentDate =
        widget.vehicle?.nextPaymentDate ?? '11-15-2024';
    final String nextPaymentDate = _formatDate(rawNextPaymentDate);
    final String policyType = widget.vehicle?.policyType ?? 'My Auto Policy';
    widget.vehicle?.providerImage ?? 'assets/home/icons/Bluefire.png';
    final bool isBluefire = widget.vehicle?.providerId == 1;

    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppTheme.getCardColor(context),
      child: Container(
        width: screenWidth - 48, // Ancho adaptable
        // Altura adaptable en lugar de fija
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera fila: Información de la póliza y estado
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: [
                // Icono del auto
                Image.asset(
                  'assets/home/icons/icon-car-1.png',
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                ),
                // Información de la póliza
                SizedBox(
                  width: screenWidth * 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policyType,
                        style: TextStyle(
                          fontSize:
                              responsiveFontSizes.policyCardTitle(context),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      Text(
                        plateNumber,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize:
                              responsiveFontSizes.policyCardSubtitle(context),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Indicador de estado (Active/Inactive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundGreenColor(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isActive
                            ? AppTheme.getGreenColor(context)
                            : AppTheme.getRedColor(context),
                        size: 14, // Reducido ligeramente
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isActive
                            ? context.translate('home.policyCard.active')
                            : context.translate('home.policyCard.inactive'),
                        style: TextStyle(
                          fontSize: responsiveFontSizes.button(
                            context,
                          ), // Reducido para asegurar que quepa
                          color: isActive
                              ? AppTheme.getGreenColor(context)
                              : AppTheme.getRedColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Segunda fila: Logo y próximo pago
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                // Logo
                isBluefire
                    ? Image.asset(
                        'assets/home/icons/Bluefire.png',
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.05,
                      )
                    : Image.asset(
                        AppTheme.getFreewayLogoType(context),
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.1,
                      ),
                const SizedBox(width: 8),
                // Información de próximo pago
                Wrap(
                  direction: Axis.horizontal,
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: AppTheme.getGreenColor(context),
                      size: screenWidth * 0.05, // Reducido ligeramente
                    ),
                    const SizedBox(width: 4),
                    // Texto "Next Payment" que se puede ocultar en pantallas muy pequeñas
                    Text(
                      context.translate('home.policyCard.nextPayment'),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.bodyMedium(
                          context,
                        ), // Reducido para asegurar que quepa
                        color: AppTheme.getTextGreyColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    const SizedBox(width: 8),
                    // Fecha del próximo pago
                    Text(
                      nextPaymentDate,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: responsiveFontSizes.bodyMedium(
                          context,
                        ), // Reducido para asegurar que quepa
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextGreyColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tercera fila: Botones de acción
            LayoutBuilder(
              builder: (context, constraints) {
                // Calcular el ancho disponible para los botones
                final availableWidth = constraints.maxWidth;
                // Determinar si estamos en una pantalla muy pequeña
                final isVerySmallScreen = availableWidth < 360;

                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 4,
                  runSpacing: 8,
                  children: [
                    // Botón ID
                    SizedBox(
                      width: isVerySmallScreen
                          ? (availableWidth * 0.28)
                          : (availableWidth * 0.28),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IdCardPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.getOrangeColor(context),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 4 : 8,
                            vertical: 0,
                          ),
                        ),
                        child: Text(
                          context.translate('home.policyCard.idCard'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize:
                                responsiveFontSizes.policyCardButton(context),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getOrangeColor(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Botón Submit
                    SizedBox(
                      width: isVerySmallScreen
                          ? (availableWidth * 0.33)
                          : (availableWidth * 0.33),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/submit-claim');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 4 : 8,
                            vertical: 0,
                          ),
                        ),
                        child: Text(
                          context.translate('home.policyCard.submitClaim'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize:
                                responsiveFontSizes.policyCardButton(context),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Botón Pay Now - Destacado
                    SizedBox(
                      width: isVerySmallScreen
                          ? (availableWidth * 0.33)
                          : (availableWidth * 0.33),
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.getGreenColor(context),
                                  AppTheme.getGreenColor(context)
                                      .withValues(alpha: 0.5),
                                  AppTheme.getGreenColor(context),
                                ],
                                stops: [
                                  0.0,
                                  _shimmerAnimation.value,
                                  1.0,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getGreenColor(context)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (context.mounted) {
                                  // Usar una única URL con número de póliza y código postal
                                  final String policyNumber =
                                      widget.user.policyNumber;
                                  final zipCode = widget.user.zipCode;
                                  final String urlString =
                                      'https://quickpay.freeway.com/PolicySearch?policyNumber=$policyNumber&zipCode=$zipCode&source=Web';
                                  final String title =
                                      context.translate('payment.title');

                                  if (context.mounted) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WebViewPage(
                                          url: urlString,
                                          title: title,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isVerySmallScreen ? 6 : 10,
                                  vertical: 0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Añadir un icono para hacerlo más llamativo
                                  Icon(
                                    Icons.payment_rounded,
                                    color: AppTheme.white,
                                    size: screenWidth * 0.05,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      context.translate(
                                        'home.policyCard.payNow',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Open Sans',
                                        fontSize: responsiveFontSizes
                                            .policyCardButtonBig(context),
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // Función para formatear la fecha en formato mes-día-año
  String _formatDate(String dateStr) {
    try {
      // Intentar analizar la fecha según varios formatos posibles
      DateTime? date;

      // Intentar formato yyyy-MM-dd
      try {
        if (dateStr.contains('-') && dateStr.length == 10) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            // Si parece ser yyyy-MM-dd
            if (parts[0].length == 4) {
              date = DateTime.parse(dateStr);
            }
            // Si parece ser MM-dd-yyyy
            else if (parts[2].length == 4) {
              date = DateTime(
                int.parse(parts[2]), // año
                int.parse(parts[0]), // mes
                int.parse(parts[1]), // día
              );
            }
          }
        }
      } catch (e) {
        // Ignorar error y continuar con otros formatos
      }

      // Si no se pudo analizar, intentar con DateFormat
      if (date == null) {
        try {
          // Intentar con formato MM-dd-yyyy
          date = DateFormat('MM-dd-yyyy').parse(dateStr);
        } catch (e) {
          try {
            // Intentar con formato dd-MM-yyyy
            date = DateFormat('dd-MM-yyyy').parse(dateStr);
          } catch (e) {
            // Si todo falla, devolver la cadena original
            return dateStr;
          }
        }
      }

      // Formatear la fecha al formato deseado (MM-dd-yyyy)
      return DateFormat('MM-dd-yyyy').format(date);
    } catch (e) {
      // En caso de error, devolver la cadena original
      return dateStr;
    }
  }
}
