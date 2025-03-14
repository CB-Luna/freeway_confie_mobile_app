import 'package:flutter/material.dart';

class PaymentCardItem extends StatelessWidget {
  final String cardNumber;
  final String expiry;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentCardItem({
    required this.cardNumber, required this.expiry, required this.imagePath, required this.isSelected, required this.onTap, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0047BB) : const Color(0xFFE8E8E8),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  imagePath,
                  width: 64,
                  height: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardNumber,
                      style: const TextStyle(
                        color: Color(0xFF414648),
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      expiry,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF0047BB) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
