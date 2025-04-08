import 'package:flutter/material.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

class PaymentCardItem extends StatelessWidget {
  final String cardNumber;
  final String expiry;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentCardItem({
    required this.cardNumber,
    required this.expiry,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context).withValues(alpha: 0.1)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getDetailsGreyColor(context),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.getPrimaryColor(context)
                        : AppTheme.getDetailsGreyColor(context),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Card logo
              Image.asset(
                imagePath,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              // Card info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cardNumber,
                    style: TextStyle(
                      color: AppTheme.getTitleTextColor(context),
                      fontSize: 16,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: TextStyle(
                      color: AppTheme.getSubtitleTextColor(context),
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
