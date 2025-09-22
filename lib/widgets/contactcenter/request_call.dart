import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/locator_device_module.dart';
import 'package:freeway_app/pages/add_insurance.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/menu/circle_nav_bar.dart';

class RequestCallPage extends StatefulWidget {
  const RequestCallPage({super.key});

  @override
  State<RequestCallPage> createState() => _RequestCallPageState();
}

class _RequestCallPageState extends State<RequestCallPage> {
  int _selectedIndex = 0;

  // Números de teléfono para los diferentes servicios
  final String _customerServicePhone = '888-443-4662';
  final String _insuranceQuotesPhone = '800-777-5620';

  // Método para abrir directamente la aplicación de llamadas del dispositivo
  Future<void> _openPhoneDialer(String phoneNumber) async {
    try {
      // Eliminar cualquier carácter no numérico del número de teléfono
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // Crear la URI para abrir la aplicación de llamadas sin iniciar la llamada
      final Uri launchUri = Uri.parse('tel:$cleanedNumber');

      // Abrir la aplicación de llamadas
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Mostrar mensaje de error si no se puede abrir la aplicación de llamadas
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.translate('requestCall.callError'),
        const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
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
              context.translate('requestCall.back'),
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Contenedor principal
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.translate('requestCall.title'),
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: responsiveFontSizes.titleLarge(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        context.translate('requestCall.subtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.getTitleTextColor(context),
                          fontSize: responsiveFontSizes.bodyMedium(context),
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Image.asset(
                        'assets/home/icons/contactagent.png',
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.25,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      context.translate('requestCall.customerService'),
                      style: TextStyle(
                        color: AppTheme.getSubtitleTextColor(context),
                        fontSize: responsiveFontSizes.bodySmall(context),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _openPhoneDialer(_customerServicePhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryColor(context),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone_in_talk,
                            color: AppTheme.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              context
                                  .translate('requestCall.callCustomerService'),
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      context.translate('requestCall.insuranceQuotes'),
                      style: TextStyle(
                        color: AppTheme.getSubtitleTextColor(context),
                        fontSize: responsiveFontSizes.bodySmall(context),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _openPhoneDialer(_insuranceQuotesPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getSecondaryColor(context),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone_in_talk,
                            color: AppTheme.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              context
                                  .translate('requestCall.callInsuranceQuotes'),
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
