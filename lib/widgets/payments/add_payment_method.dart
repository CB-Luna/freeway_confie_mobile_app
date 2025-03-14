import 'package:flutter/material.dart';

class AddPaymentMethod extends StatelessWidget {
  final VoidCallback onTap;

  const AddPaymentMethod({
    required this.onTap, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add New Method',
              style: TextStyle(
                color: Color(0xFF0047BB),
                fontSize: 16,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF0047BB),
            ),
          ],
        ),
      ),
    );
  }
}
