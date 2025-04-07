import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

import '../contactcenter/request_call.dart';

class ContactAgent extends StatelessWidget {
  const ContactAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getBoxShadowColor(context),
            offset: const Offset(0, 2),
            blurRadius: 13,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/home/icons/contactagent.png',
                width: 47,
                height: 36,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('home.contactAgent.needChanges'),
                    style: TextStyle(
                      color: AppTheme.getOrangeColor(context),
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 18 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    context.translate('home.contactAgent.contactMyAgent'),
                    style: TextStyle(
                      color: AppTheme.getPrimaryColor(context),
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 18 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestCallPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getPrimaryColor(context),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              context.translate('home.contactAgent.callNow'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.white,
                fontFamily: 'Open Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 18 / 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
