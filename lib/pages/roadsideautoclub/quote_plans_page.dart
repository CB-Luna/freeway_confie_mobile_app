import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../models/quote_plan.dart';
import '../../../utils/menu/circle_nav_bar.dart';
import 'quote_plans_card.dart';

class QuotePlansPage extends StatefulWidget {
  const QuotePlansPage({super.key});

  @override
  State<QuotePlansPage> createState() => _QuotePlansPageState();
}

class _QuotePlansPageState extends State<QuotePlansPage> {
  bool _isMonthly = true;
  int _selectedNavIndex = 1;
  int? _selectedPlanIndex;

  final List<TabData> _navItems = [
    TabData(Icons.home, 'My Products'),
    TabData(Icons.verified_user, '+Add Insurance'),
    TabData(Icons.location_on, 'Location'),
  ];

  final List<QuotePlan> _plans = [
    QuotePlan(
      title: 'Single Plan',
      iconPath: 'assets/products/vehicle/auto.svg',
      monthlyPrice: 12.0,
      annualPrice: 99.0,
      isPopular: true,
      primaryColor: const Color(0xFFE65100),
      accentColor: const Color(0xFFC74E10),
      features: [
        PlanFeature(
          title: 'One Person',
          iconPath: 'assets/icons/person.svg',
        ),
        PlanFeature(
          title: 'Unlimited Usage',
          subtitle: '(Per 7 Day Period)',
          iconPath: 'assets/icons/unlimited.svg',
        ),
        PlanFeature(
          title: 'Nationwide Coverage',
          iconPath: 'assets/icons/coverage.svg',
        ),
        PlanFeature(
          title: 'Light Duty Vehicle',
          iconPath: 'assets/icons/vehicle.svg',
        ),
      ],
    ),
    QuotePlan(
      title: 'Family Plan',
      iconPath: 'assets/products/vehicle/auto.svg',
      monthlyPrice: 17.0,
      annualPrice: 149.0,
      isPopular: false,
      primaryColor: const Color(0xFF0046B9),
      accentColor: const Color(0xFF0046B9),
      features: [
        PlanFeature(
          title: 'One Person',
          iconPath: 'assets/icons/person.svg',
        ),
        PlanFeature(
          title: 'Unlimited Usage',
          subtitle: '(Per 7 Day Period)',
          iconPath: 'assets/icons/unlimited.svg',
        ),
        PlanFeature(
          title: 'Nationwide Coverage',
          iconPath: 'assets/icons/coverage.svg',
        ),
        PlanFeature(
          title: 'Light Duty Vehicle',
          iconPath: 'assets/icons/vehicle.svg',
        ),
      ],
    ),
    // Aquí puedes agregar más planes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FCFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF0046B9),
                  size: 20,
                ),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF0046B9),
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: CircleNavBar(
          tabItems: _navItems,
          selectedPos: _selectedNavIndex,
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
            if (index == 0) {
              // Home button
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (route) => false);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Freeway Auto Club',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
                color: Color(0xFF0046B9),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select plan',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0046B9),
              ),
            ),
            const Text(
              'you will use for this quote',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            _buildPlanTypeToggle(),
            const SizedBox(height: 40),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _plans
                    .asMap()
                    .entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: QuotePlanCard(
                            plan: entry.value,
                            onRequestQuote: () => _onRequestQuote(entry.value),
                            isSelected: _selectedPlanIndex == entry.key,
                            isMonthly: _isMonthly,
                          ),
                        ),)
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRequestQuote(QuotePlan plan) {
    setState(() {
      _selectedPlanIndex = _plans.indexOf(plan);
    });
    // Implementar la lógica para solicitar cotización
  }

  Widget _buildPlanTypeToggle() {
    return Container(
      width: 318,
      height: 80,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ToggleSwitch(
          minWidth: 150.0,
          cornerRadius: 30.0,
          activeBgColors: [
            [const Color(0xFF0046B9)],
            [const Color(0xFF0046B9)],
          ],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.white,
          inactiveFgColor: Colors.black87,
          initialLabelIndex: _isMonthly ? 0 : 1,
          totalSwitches: 2,
          customWidgets: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
                    color: _isMonthly ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: _isMonthly ? Colors.white : Colors.transparent,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Annually',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
                    color: !_isMonthly ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: !_isMonthly ? Colors.white : Colors.transparent,
                ),
              ],
            ),
          ],
          radiusStyle: true,
          animate: true,
          animationDuration: 200,
          onToggle: (index) {
            setState(() {
              _isMonthly = index == 0;
            });
          },
        ),
      ),
    );
  }
}
