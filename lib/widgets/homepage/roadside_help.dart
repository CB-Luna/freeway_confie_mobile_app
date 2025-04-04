import 'package:flutter/material.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

import '../../pages/roadsideautoclub/quote_plans_page.dart';

class RoadsideHelp extends StatelessWidget {
  const RoadsideHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 377,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: AppTheme.getCardColor(context),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuotePlansPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Need Roadside Help?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextGreyColor(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Add Freeway Auto Club',
                        style: TextStyle(
                          color: AppTheme.getPrimaryColor(context),
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 18 / 14,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 93,
                      height: 29,
                      child: Image.asset(
                        'assets/home/icons/truckwhite.png',
                        width: 93,
                        height: 28.999996185302734,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.getDetailsGreyColor(context),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
