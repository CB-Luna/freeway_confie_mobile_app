import 'package:acceptance_app/data/models/auth/policy_model.dart';
import 'package:acceptance_app/locatordevice/locator_device_module.dart';
import 'package:acceptance_app/pages/add_insurance.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../../utils/menu/circle_nav_bar.dart';
import '../../widgets/submitclaim/custom_claim_card.dart';
import '../../widgets/submitclaim/safety_check_card.dart';

class SubmitClaimPage extends StatefulWidget {
  final PolicyModel? policy;

  const SubmitClaimPage({
    this.policy,
    super.key,
  });

  @override
  State<SubmitClaimPage> createState() => _SubmitClaimPageState();
}

class _SubmitClaimPageState extends State<SubmitClaimPage> {
  int _selectedIndex = 0;
  bool _showBluefireCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 56,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              context.translate('submitClaim.back'),
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Contenedor principal
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        context.translate('submitClaim.title'),
                        style: TextStyle(
                          color: AppTheme.getTitleTextColor(context),
                          fontSize: responsiveFontSizes.titleLarge(context),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: _showBluefireCard
                    ? CustomClaimCard(policy: widget.policy)
                    : SafetyCheckCard(
                        onSafetyConfirmed: () {
                          setState(() {
                            _showBluefireCard = true;
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CircleNavBar(
        selectedPos: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddInsurancePage(),
                ),
              ).then((_) => setState(() => _selectedIndex = 0));
              break;
            case 2:
              LocatorDeviceModule.navigateToLocationView(context);
              break;
          }
        },
        tabItems: [
          TabData(
            Icons.home_outlined,
            context.translate('home.navigation.myProducts'),
          ),
          TabData(
            Icons.verified_user_outlined,
            context.translate('home.navigation.addInsurance'),
          ),
          TabData(
            Icons.location_on_outlined,
            context.translate('home.navigation.location'),
          ),
        ],
      ),
    );
  }
}
