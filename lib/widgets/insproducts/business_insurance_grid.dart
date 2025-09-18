import 'package:acceptance_app/data/constants.dart';
import 'package:acceptance_app/data/services/web_dialog_service.dart';
import 'package:acceptance_app/models/user_model.dart';
import 'package:acceptance_app/providers/auth_provider.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/location_service.dart';
import '../../locatordevice/locator_device_module.dart';
import '../../locatordevice/presentation/widgets/loading_view.dart';
import '../../pages/home_page.dart';
import '../../pages/webview_page.dart';
import '../../utils/menu/circle_nav_bar.dart';
import '../../widgets/common/custom_dialog.dart';
import 'zip_code_dialog.dart';

class BusinessInsuranceGrid extends StatefulWidget {
  const BusinessInsuranceGrid({super.key});

  @override
  State<BusinessInsuranceGrid> createState() => _BusinessInsuranceGridState();
}

class _BusinessInsuranceGridState extends State<BusinessInsuranceGrid> {
  int _selectedIndex = 1; // Inicializado en 1 para 'Add Insurance'
  final LocationService _locationService = LocationService();
  bool _isProcessingBusinessInsurance =
      false; // Bandera para evitar múltiples llamadas

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaler;
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
              context.translate('businessInsurance.back'),
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
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
                  context.translate('businessInsurance.title'),
                  style: TextStyle(
                    color: AppTheme.getTitleTextColor(context),
                    fontSize: responsiveFontSizes.titleSmall(context),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: textScale.scale(1) > 1.5
                    ? 2
                    : textScale.scale(1) > 1
                        ? 2
                        : 3,
                mainAxisSpacing: textScale.scale(1) > 1.5
                    ? 18.0
                    : textScale.scale(1) > 1
                        ? 14.0
                        : 10.0,
                crossAxisSpacing: textScale.scale(1) > 1.5
                    ? 18.0
                    : textScale.scale(1) > 1
                        ? 14.0
                        : 10.0,
                childAspectRatio: textScale.scale(1) > 1.5
                    ? 0.75
                    : textScale.scale(1) > 1
                        ? 0.85
                        : 0.9,
                children: [
                  _buildInsuranceItem(
                    context,
                    context.translate('businessInsurance.businessInsurance'),
                    'business_insurance',
                  ),
                ],
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
    );
  }

  Widget _buildInsuranceItem(
    BuildContext context,
    String title,
    String iconName,
  ) {
    // Ajustar el tamaño de fuente basado en el ancho disponible
    final fontSize = responsiveFontSizes.labelLarge(context);

    return GestureDetector(
      onTap: () {
        // Evitar múltiples llamadas mientras se procesa una solicitud
        if (!_isProcessingBusinessInsurance) {
          // Determinar qué tipo de seguro se ha seleccionado
          if (title ==
              context.translate('businessInsurance.businessInsurance')) {
            _handleBusinessInsurance(context);
          } else if (title == context.translate('businessInsurance.landlord')) {
            _handleLandlord(context);
          } else if (title ==
              context.translate('businessInsurance.commercialAuto')) {
            _handleCommercialAuto(context);
          } else if (title ==
              context.translate('businessInsurance.rideShareInsurance')) {
            _handleRideShareInsurance(context);
          } else {
            // Para cualquier otro tipo no reconocido
            _showNotAvailableMessage(context, title);
          }
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/products/businesspng/4.0x/$iconName.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business,
                    size: 48,
                    color: AppTheme.getPrimaryColor(context),
                  );
                },
              ),
              const SizedBox(height: 8),
              Container(
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextGreyColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para manejar el seguro de auto con geolocalización
  // Método genérico para manejar cualquier tipo de seguro
  Future<void> _handleInsurance(
    BuildContext context,
    String insuranceType,
  ) async {
    // Establecer la bandera para evitar múltiples llamadas
    setState(() {
      _isProcessingBusinessInsurance = true;
    });

    // Mostrar un indicador de progreso
    final overlay = LoadingView.showOverlay(
      context,
      message: context.translate('businessInsurance.processing'),
      indicatorColor: AppTheme.getPrimaryColor(context),
      textColor: AppTheme.getTitleTextColor(context),
    );

    try {
      // Obtener información del usuario actual
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      final String zipCode = user?.zipCode ?? ''; // Acceso seguro a zipCode

      // Validar el código postal con la API de Zippopotam
      final placeInfo = await _locationService.validateZipCode(zipCode);

      // Ocultar el indicador de progreso
      overlay.remove();

      if (!context.mounted) {
        setState(() {
          _isProcessingBusinessInsurance = false;
        });
        return;
      }

      if (placeInfo != null) {
        // Si el código postal es válido, mostrar directamente el diálogo de página web
        await _showWebPageDialog(
          context,
          zipCode,
          placeInfo['placeName'],
          placeInfo['stateAbbreviation'],
          insuranceType,
        );
      } else {
        // Si el código postal no es válido, permitir al usuario ingresarlo manualmente
        await _showZipCodeDialog(context, zipCode, insuranceType);
      }
    } catch (e) {
      debugPrint('Error al procesar la solicitud: $e');

      // Ocultar el indicador de progreso
      overlay.remove();

      if (!context.mounted) {
        setState(() {
          _isProcessingBusinessInsurance = false;
        });
        return;
      }

      // En caso de error, permitir al usuario ingresar el código postal manualmente
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      await _showZipCodeDialog(context, user?.zipCode ?? '', insuranceType);
    } finally {
      // Restablecer la bandera después de completar el proceso
      setState(() {
        _isProcessingBusinessInsurance = false;
      });
    }
  }

  // Métodos específicos para cada tipo de seguro
  Future<void> _handleBusinessInsurance(BuildContext context) async {
    await _handleInsurance(context, 'business_insurance');
  }

  Future<void> _handleLandlord(BuildContext context) async {
    await _handleInsurance(context, 'landlord');
  }

  Future<void> _handleCommercialAuto(BuildContext context) async {
    await _handleInsurance(context, 'commercial_auto');
  }

  Future<void> _handleRideShareInsurance(BuildContext context) async {
    await _handleInsurance(context, 'ride_share_insurance');
  }

  // Método para mostrar mensaje cuando un seguro no está disponible
  void _showNotAvailableMessage(BuildContext context, String insuranceType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$insuranceType ${context.translate('businessInsurance.notAvailableMessage')}',
        ),
        backgroundColor: AppTheme.getOrangeColor(context),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      _isProcessingBusinessInsurance = false;
    });
  }

  // Método para mostrar el diálogo de código postal
  Future<void> _showZipCodeDialog(
    BuildContext context,
    String? initialZipCode,
    String insuranceType,
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
          insuranceType,
        );
      } else if (context.mounted) {
        // Si el código postal no es válido, mostrar un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('businessInsurance.location.invalidZipCode'),
            ),
            backgroundColor: AppTheme.getRedColor(context),
          ),
        );
      }
    }

    // Proceso completado
  }

  // Método para mostrar el diálogo de página web
  Future<void> _showWebPageDialog(
    BuildContext context,
    String zipCode,
    String placeName,
    String stateAbbreviation,
    String insuranceType,
  ) async {
    // Obtener información del usuario actual para prellenar formularios
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Formatear fecha de nacimiento si está disponible
    String formatBirthDate(User? user) {
      // Si no hay usuario o no hay fecha de nacimiento disponible, devolver vacío
      if (user == null) return '';

      try {
        // Intentar obtener la fecha de nacimiento del usuario
        // Nota: Asumimos que podría estar en algún campo como nextPayment solo para tener una fecha
        // En una implementación real, deberías tener un campo específico para birthDate en el modelo User
        final date = user.birthDate;
        // Formato MM/DD/YYYY que suelen usar los formularios en EE.UU.
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        debugPrint('Error al formatear fecha de nacimiento: $e');
        return '';
      }
    }

    // Preparar datos del usuario para pasar a los formularios
    final Map<String, String> userData = {
      'firstName': user?.fullName.split(' ').first ?? '',
      'lastName': user?.fullName.split(' ').isNotEmpty == true &&
              user!.fullName.split(' ').length > 1
          ? user.fullName.split(' ').skip(1).join(' ')
          : '',
      'email': user?.email ?? '',
      'phone': user?.phone ?? '',
      'zipCode': zipCode,
      'city': placeName,
      'state': stateAbbreviation,
      'birthDate': formatBirthDate(user),
      'street': user?.street ?? '',
    };

    // Verificar si ya se ha mostrado el diálogo anteriormente
    final webDialogService = WebDialogService();
    final hasBeenShown = await webDialogService.hasWebDialogBeenShown();

    bool shouldProceed = true;

    // Solo mostrar el diálogo si no se ha mostrado antes
    if (!hasBeenShown && context.mounted) {
      final result = await CustomDialog.show(
        context: context,
        title: context.translate('businessInsurance.location.webDialogTitle'),
        message: context
            .translate('businessInsurance.location.webDialogMessage')
            .replaceAll('{0}', placeName)
            .replaceAll('{1}', stateAbbreviation),
        positiveButtonText:
            context.translate('businessInsurance.location.visitWebsite'),
        negativeButtonText:
            context.translate('businessInsurance.location.cancel'),
      );

      // Marcar el diálogo como mostrado
      await webDialogService.setWebDialogShown();

      shouldProceed = result == true;
    }

    if (shouldProceed && context.mounted) {
      // Determinar la URL basada en el tipo de seguro
      String urlString;
      String title;

      switch (insuranceType) {
        case 'business_insurance':
          urlString =
              '${urlBaseEmbed}business-insurance-quote-form/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('businessInsurance.businessInsurance')} - $placeName, $stateAbbreviation';
          break;
        case 'landlord':
          urlString =
              'https://www.freeway.com/landlord-insurance-quote-form/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('businessInsurance.landlord')} - $placeName, $stateAbbreviation';
          break;
        case 'commercial_auto':
          urlString =
              'https://www.freeway.com/commercial-vehicle-insurance-quote-form/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('businessInsurance.commercialAuto')} - $placeName, $stateAbbreviation';
          break;
        case 'rideshare_insurance':
          urlString = 'https://rate.freeway.com/';
          title = context.translate('businessInsurance.rideShareInsurance');
          break;
        default:
          urlString = 'https://www.freeway.com/';
          title = context.translate('businessInsurance.title');
      }

      // Abrir la URL en un WebView embebido en lugar de un navegador externo
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              url: urlString,
              title: title,
              userData: userData,
              formType:
                  insuranceType, // Pasar el tipo de seguro para el autocompletado
            ),
          ),
        );
      }
    }

// Proceso completado
  }
}
