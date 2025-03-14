import 'package:flutter/material.dart';

class BillingInfoCard extends StatelessWidget {
  final String name;
  final String address;
  final String total;

  const BillingInfoCard({
    required this.name, required this.address, required this.total, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 323,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              child: Stack(
                children: [
                  const Positioned(
                    top: 20,
                    left: 0,
                    child: Text(
                      'Billing Address',
                      style: TextStyle(
                        color: Color(0xFF0047BB),
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF1D1D1D),
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address,
                          style: const TextStyle(
                            color: Color(0xFF1D1D1D),
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF95AFC0),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Total:',
                  style: TextStyle(
                    color: Color(0xFFC74E10),
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    height: 24 / 16,
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    color: Color(0xFFC74E10),
                    fontSize: 20,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    height: 18 / 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
