import 'package:flutter/material.dart';

import '../../pages/home_page.dart';
import '../../utils/menu/circle_nav_bar.dart';
import '../../widgets/common/custom_dialog.dart';
import 'motorcycle_insurance_page.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleInsuranceGrid extends StatefulWidget {
  const VehicleInsuranceGrid({super.key});

  @override
  State<VehicleInsuranceGrid> createState() => _VehicleInsuranceGridState();
}

class _VehicleInsuranceGridState extends State<VehicleInsuranceGrid> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FCFF),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Select a product to start your quote',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildInsuranceItem(context, 'Auto', 'auto'),
                  _buildInsuranceItem(context, 'Motorcycle', 'motorcycle'),
                  _buildInsuranceItem(context, 'Motorhome', 'motorhome'),
                  _buildInsuranceItem(context, 'RV/\nMotorhome', 'motorhome'),
                  _buildInsuranceItem(context, 'ATV', 'atv'),
                  _buildInsuranceItem(context, 'Snowmobile', 'snowmobile'),
                  _buildInsuranceItem(context, 'SR-22\nInsurance', 'SR-22'),
                  _buildInsuranceItem(context, 'Classic Car', 'Classi-Car'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: CircleNavBar(
          selectedPos: 1,
          tabItems: [
            TabData(Icons.home_outlined, 'My Products'),
            TabData(Icons.verified_user_outlined, '+ Add Insurance'),
            TabData(Icons.location_on_outlined, 'Location'),
          ],
          onTap: (index) {
            switch (index) {
              case 0: // My Products
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
              case 1: // Add Insurance
                // Ya estamos en Add Insurance
                break;
              case 2: // Location
                // TODO: Implementar navegación a Location
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildInsuranceItem(
    BuildContext context,
    String title,
    String iconName,
  ) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case 'Auto':
            _showWebPageDialog(context);
            break;
          case 'Motorcycle':
            _showMotorcycleDialog(context);
            break;
          // TODO: Implementar navegación para otros tipos de seguro
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/products/vehiclepng/4.0x/$iconName.png',
              height: 40,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar el diálogo de página web
  Future<void> _showWebPageDialog(BuildContext context) async {
    final bool? result = await CustomDialog.show(
      context: context,
      title: 'Web Page Inside the App',
      content: 'You are about to open a web page within the app to complete this action. Please follow the instructions there.',
      onConfirm: () async {
        // Abrir la URL en el navegador
        final Uri url = Uri.parse('https://www.freeway.com/');
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.inAppWebView);
          } else {
            // Si no se puede abrir en modo inAppWebView, intentar con el navegador externo
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          // Mostrar un mensaje de error si no se puede abrir la URL
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open the website. Please try again later.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      },
    );
  }

  // Método para mostrar el diálogo de motocicleta
  Future<void> _showMotorcycleDialog(BuildContext context) async {
    final bool? result = await CustomDialog.show(
      context: context,
      title: 'Motorcycle Insurance',
      content: 'You\'re about to get a quote for motorcycle insurance. Would you like to proceed?',
      confirmText: 'Get Quote',
      cancelText: 'Not Now',
      onConfirm: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MotorcycleInsurancePage(),
          ),
        );
      },
    );
  }
}
