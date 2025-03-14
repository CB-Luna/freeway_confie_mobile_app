import 'package:flutter/material.dart';
import '../../../pages/roadsideautoclub/quote_plans_page.dart';

class OptionsCoverCard extends StatelessWidget {
  final String logoPath;
  final double price;
  final VoidCallback onCoverageDetails;
  final VoidCallback onContinue;
  final bool isSelected;

  const OptionsCoverCard({
    required this.logoPath, required this.price, required this.onCoverageDetails, required this.onContinue, super.key,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF0046B9) : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Company logo
                Image.asset(
                  logoPath,
                  width: 100,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                // Precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          price.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          '/mo*',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Average in your state*',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Open Sans',
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón de detalles de cobertura
          TextButton(
            onPressed: onCoverageDetails,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'See Auto Coverages Details',
                  style: TextStyle(
                    color: Color(0xFF0046B9),
                    fontSize: 14,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 20,
                ),
              ],
            ),
          ),
          // Botón Continue
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuotePlansPage(),
                  ),
                );
                onContinue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF76707),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
