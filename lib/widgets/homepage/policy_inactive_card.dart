import 'package:flutter/material.dart';

import '../../data/models/home_policy/vehicle.dart';
import '../../widgets/theme/app_theme.dart';

class PolicyInactiveCard extends StatelessWidget {
  final dynamic user;
  final String policyNumber;
  final Vehicle? vehicle;

  const PolicyInactiveCard({
    required this.user,
    required this.policyNumber,
    super.key,
    this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    // Imprimir el policyNumber para depuración

    // Usar policyNumber como plateNumber
    final String plateNumber = vehicle?.plate ?? policyNumber;
    final String policyType = vehicle?.policyType ?? 'My Auto Policy';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppTheme.getCardColor(context),
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 180,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: AppTheme.grey,
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
                          color: AppTheme.grey,
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
                    color: Colors.red.withAlpha(50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Inactive',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Botón de renovar póliza
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Acción para renovar la póliza
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getGreenColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Renew Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
