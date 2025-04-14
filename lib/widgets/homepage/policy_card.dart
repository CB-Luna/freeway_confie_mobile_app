import 'package:flutter/material.dart';
import 'package:freeway_app/pages/webview_page.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:intl/intl.dart';

import '../../data/models/home_policy/vehicle.dart';
import '../../pages/id_card_page.dart';
import '../../widgets/payments/payment_search_dialog.dart';
import '../../widgets/theme/app_theme.dart';

class PolicyCard extends StatefulWidget {
  final dynamic user;
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primera fila: Información de la póliza y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del auto
                Image.asset(
                  'assets/home/icons/icon-car-1.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 12),
                // Información de la póliza
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policyType,
                        style: TextStyle(
                          fontSize: 18, // Reducido ligeramente
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        plateNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getPrimaryColor(context),
                        ),
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
                          fontSize: 12, // Reducido para asegurar que quepa
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
            Row(
              children: [
                // Logo
                isBluefire
                    ? Image.asset(
                        'assets/home/icons/Bluefire.png',
                        width: 80,
                        height: 22,
                      )
                    : Image.asset(
                        AppTheme.getFreewayLogoType(context),
                        width: 80,
                        height: 22,
                      ),
                const SizedBox(width: 8),
                // Información de próximo pago
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: AppTheme.getGreenColor(context),
                        size: 14, // Reducido ligeramente
                      ),
                      const SizedBox(width: 4),
                      // Texto "Next Payment" que se puede ocultar en pantallas muy pequeñas
                      Flexible(
                        child: Text(
                          context.translate('home.policyCard.nextPayment'),
                          style: TextStyle(
                            fontSize: 12, // Reducido para asegurar que quepa
                            color: AppTheme.getTextGreyColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Fecha del próximo pago
                      Flexible(
                        child: Text(
                          nextPaymentDate,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 12, // Reducido para asegurar que quepa
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextGreyColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                final isVerySmallScreen = availableWidth < 300;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón ID
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 38,
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.translate('home.policyCard.idCard'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getOrangeColor(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Botón Submit
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 38,
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.translate('home.policyCard.submitClaim'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Botón Pay Now - Destacado
                    Expanded(
                      flex: 3, // Aumentar el flex para darle más espacio
                      child: SizedBox(
                        height:
                            38, // Altura ligeramente mayor que los otros botones
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
                                  final result = await PaymentSearchDialog.show(
                                    context: context,
                                    initialZipCode:
                                        null, // Usar null para que se active la geolocalización
                                  );

                                  if (result != null && context.mounted) {
                                    final zipCode = result['zipCode'];
                                    final searchType =
                                        result['searchType'] as SearchType;

                                    String urlString;
                                    String title;

                                    if (searchType == SearchType.policyNumber) {
                                      urlString =
                                          'https://quickpay.freeway.com/PolicySearch?zipCode=$zipCode';
                                      title = context.translate(
                                        'payment.search.byPolicyNumber',
                                      );
                                    } else {
                                      urlString =
                                          'https://quickpay.freeway.com/?zipCode=$zipCode';
                                      title = context.translate(
                                        'payment.search.byPhoneNumber',
                                      );
                                    }

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
                                    const Icon(
                                      Icons.payment_rounded,
                                      color: AppTheme.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        context.translate(
                                          'home.policyCard.payNow',
                                        ),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize:
                                              14, // Ligeramente más grande
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
