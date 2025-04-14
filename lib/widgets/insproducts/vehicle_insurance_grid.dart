import 'package:flutter/material.dart';
import 'package:freeway_app/data/services/web_dialog_service.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/services/location_service.dart';
import '../../locatordevice/locator_device_module.dart';
import '../../locatordevice/presentation/widgets/loading_view.dart';
import '../../pages/home_page.dart';
import '../../pages/webview_page.dart';
import '../../utils/menu/circle_nav_bar.dart';
import '../../widgets/common/custom_dialog.dart';
import 'zip_code_dialog.dart';

class VehicleInsuranceGrid extends StatefulWidget {
  const VehicleInsuranceGrid({super.key});

  @override
  State<VehicleInsuranceGrid> createState() => _VehicleInsuranceGridState();
}

class _VehicleInsuranceGridState extends State<VehicleInsuranceGrid> {
  int _selectedIndex = 1; // Inicializado en 1 para 'Add Insurance'
  final LocationService _locationService = LocationService();
  bool _isProcessingAutoInsurance = false;

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
              context.translate('vehicleInsurance.back'),
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  context.translate('vehicleInsurance.title'),
                  style: TextStyle(
                    color: AppTheme.getTitleTextColor(context),
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
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.auto'),
                    'auto',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.motorcycle'),
                    'motorcycle',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.motorhome'),
                    'motorhome',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.rvMotorhome'),
                    'motorhome',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.atv'),
                    'atv',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.snowmobile'),
                    'snowmobile',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.sr22Insurance'),
                    'SR-22',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.classicCar'),
                    'Classi-Car',
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildInsuranceItem(
    BuildContext context,
    String title,
    String iconName,
  ) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case 'Auto':
          case 'auto':
            // Evitar múltiples llamadas mientras se procesa una solicitud
            if (!_isProcessingAutoInsurance) {
              _handleAutoInsurance(context);
            }
            break;
          // TODO: Implementar navegación para otros tipos de seguro
        }
      },
      child: Card(
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
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextGreyColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para manejar el seguro de auto con geolocalización
  Future<void> _handleAutoInsurance(BuildContext context) async {
    // Establecer la bandera para evitar múltiples llamadas
    setState(() {
      _isProcessingAutoInsurance = true;
    });

    // Mostrar un indicador de progreso
    final overlay = LoadingView.showOverlay(
      context,
      message: context.translate('vehicleInsurance.location.gettingLocation'),
      indicatorColor: AppTheme.getPrimaryColor(context),
      textColor: AppTheme.getTitleTextColor(context),
    );

    try {
      // Verificar si los servicios de ubicación están habilitados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Si los servicios de ubicación no están habilitados, mostrar diálogo sin código postal
        if (!context.mounted) return;
        await _showZipCodeDialog(context, null);
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Si los permisos son denegados, mostrar diálogo sin código postal
          if (!context.mounted) return;
          await _showZipCodeDialog(context, null);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Si los permisos están denegados permanentemente, mostrar diálogo sin código postal
        if (!context.mounted) return;
        await _showZipCodeDialog(context, null);
        return;
      }

      // Obtener la posición actual
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Realizar reverse geocoding para obtener el código postal
      final String? zipCode = await _locationService.getZipCodeFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Mostrar el diálogo con el código postal obtenido
      if (!context.mounted) return;
      // Ocultar el indicador de progreso
      overlay.remove();

      if (!context.mounted) {
        setState(() {
          _isProcessingAutoInsurance = false;
        });
        return;
      }

      await _showZipCodeDialog(context, zipCode);

      // Restablecer la bandera después de completar el proceso
      setState(() {
        _isProcessingAutoInsurance = false;
      });
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');

      // Ocultar el indicador de progreso
      overlay.remove();

      // En caso de error, mostrar diálogo sin código postal
      if (!context.mounted) {
        setState(() {
          _isProcessingAutoInsurance = false;
        });
        return;
      }

      await _showZipCodeDialog(context, null);

      // Restablecer la bandera después de completar el proceso
      setState(() {
        _isProcessingAutoInsurance = false;
      });
    }
  }

  // Método para mostrar el diálogo de código postal
  Future<void> _showZipCodeDialog(
    BuildContext context,
    String? initialZipCode,
  ) async {
    final String? zipCode = await ZipCodeDialog.show(
      context: context,
      initialZipCode: initialZipCode,
    );

    if (zipCode != null && context.mounted) {
      // Validar el código postal con la API de Zippopotam
      final placeInfo = await _locationService.validateZipCode(zipCode);

      if (placeInfo != null && context.mounted) {
        // Si el código postal es válido, mostrar el diálogo de página web
        await _showWebPageDialog(
          context,
          zipCode,
          placeInfo['placeName'],
          placeInfo['stateAbbreviation'],
        );
      } else if (context.mounted) {
        // Si el código postal no es válido, mostrar un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('vehicleInsurance.location.invalidZipCode'),
            ),
            backgroundColor: AppTheme.getRedColor(context),
          ),
        );
      }
    }

    // Restablecer la bandera después de completar el proceso
    setState(() {
      _isProcessingAutoInsurance = false;
    });
  }

  // Método para mostrar el diálogo de página web
  Future<void> _showWebPageDialog(
    BuildContext context,
    String zipCode,
    String placeName,
    String stateAbbreviation,
  ) async {
    // Verificar si ya se ha mostrado el diálogo anteriormente
    final webDialogService = WebDialogService();
    final hasBeenShown = await webDialogService.hasWebDialogBeenShown();

    bool shouldProceed = true;

    // Solo mostrar el diálogo si no se ha mostrado antes
    if (!hasBeenShown && context.mounted) {
      final result = await CustomDialog.show(
        context: context,
        title: context.translate('vehicleInsurance.location.webDialogTitle'),
        message: context
            .translate('vehicleInsurance.location.webDialogMessage')
            .replaceAll('{0}', placeName)
            .replaceAll('{1}', stateAbbreviation),
        positiveButtonText:
            context.translate('vehicleInsurance.location.visitWebsite'),
        negativeButtonText:
            context.translate('vehicleInsurance.location.cancel'),
      );

      // Marcar el diálogo como mostrado
      await webDialogService.setWebDialogShown();

      shouldProceed = result == true;
    }

    if (shouldProceed && context.mounted) {
      final urlString =
          'https://triton.freeway.com/?media_code=FWYCA-A-WW-WS-E-05884&phone=877-699-2436&zip_code=$zipCode&city=$placeName&state=$stateAbbreviation&system=atalaya';

      // Abrir la URL en un WebView embebido en lugar de un navegador externo
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            url: urlString,
            title:
                '${context.translate('vehicleInsurance.auto')} - $placeName, $stateAbbreviation',
          ),
        ),
      );
    }
  }
}
