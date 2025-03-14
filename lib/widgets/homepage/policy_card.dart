import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/home_policy/vehicle.dart';
import '../../pages/id_card_page.dart';
import '../../widgets/theme/app_theme.dart';
import '../payments/payment_now.dart';

class PolicyCard extends StatelessWidget {
  final dynamic user;
  final Vehicle? vehicle;

  const PolicyCard({
    required this.user,
    super.key,
    this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final String plateNumber = vehicle?.plate ?? 'POLICY-1';
    final bool isActive = vehicle?.status ?? true;
    final String rawNextPaymentDate = vehicle?.nextPaymentDate ?? '11-15-2024';
    final String nextPaymentDate = _formatDate(rawNextPaymentDate);
    final String policyType = vehicle?.policyType ?? 'My Auto Policy';
    vehicle?.providerImage ?? 'assets/home/icons/Bluefire.png';
    final bool isBluefire = vehicle?.providerId == 1;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 180,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/home/icons/icon-car-1.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policyType,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        plateNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isActive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isBluefire
                    ? Image.asset(
                        'assets/home/icons/Bluefire.png',
                        width: 92,
                        height: 24,
                      )
                    : Image.asset(
                        'assets/home/icons/logo_freeway.png',
                        width: 92,
                        height: 24,
                      ),
                const SizedBox(width: 4),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/home/icons/cardgreen.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Next Payment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF414648),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          nextPaymentDate,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF414648),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 90,
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
                      side: const BorderSide(
                        color: Color(0xFFC74E10),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      minimumSize: const Size(90, 38),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'ID Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 18 / 14, // line-height: 18px
                        letterSpacing: 0,
                        color: Color(0xFFC74E10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 136,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/submit-claim');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0047BB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    ),
                    child: const Text(
                      'Submit a Claim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 18 / 14, // line-height: 18px
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 82,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentNowPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64A520),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Pay Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 18 / 14, // line-height: 18px
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
