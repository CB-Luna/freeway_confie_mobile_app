import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

import '../locatordevice/locator_device_module.dart';
import '../utils/menu/circle_nav_bar.dart';
import '../widgets/homepage/header_section.dart';
import '../widgets/insproducts/insurance_card.dart';
import 'home_page.dart';

class AddInsurancePage extends StatefulWidget {
  const AddInsurancePage({super.key});

  @override
  State<AddInsurancePage> createState() => _AddInsurancePageState();
}

class _AddInsurancePageState extends State<AddInsurancePage> {
  int _selectedIndex = 1; // Inicializado en 1 para 'Add Insurance'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(73),
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: HeaderSection(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      context.translate('addInsurance.addInsurance'),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.titleMedium(context),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTitleTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InsuranceCard(
              title: context.translate('addInsurance.vehicleInsurance'),
              imagePath: 'assets/products/4.0x/vehicle.png',
              route: '/vehicle-insurance',
              imageWidth: 220,
              imageHeight: 90,
            ),
            InsuranceCard(
              title: context.translate('addInsurance.propertyInsurance'),
              imagePath: 'assets/products/4.0x/property.png',
              route: '/property-insurance',
              imageWidth: 150,
              imageHeight: 70,
            ),
            InsuranceCard(
              title: context.translate('addInsurance.personalProtection'),
              imagePath: 'assets/products/4.0x/personal.png',
              route: '/personal-protection',
              imageWidth: 152,
              imageHeight: 65,
            ),
            InsuranceCard(
              title: context.translate('addInsurance.businessInsurance'),
              imagePath: 'assets/products/4.0x/business.png',
              route: '/business-insurance',
              imageWidth: 160,
              imageHeight: 60,
            ),
            InsuranceCard(
              title: context.translate('addInsurance.additionalProducts'),
              imagePath: 'assets/products/4.0x/additional.png',
              route: '/additional-products',
              imageWidth: 139,
              imageHeight: 60,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: const Offset(0, 0),
        child: CircleNavBar(
          selectedPos: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 0: // My Products
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
              case 2: // Location
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
      ),
    );
  }
}
