import 'package:flutter/material.dart';
import 'package:freeway_app/data/services/web_dialog_service.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../data/services/location_service.dart';
import '../../locatordevice/locator_device_module.dart';
import '../../locatordevice/presentation/widgets/loading_view.dart';
import '../../pages/home_page.dart';
import '../../pages/webview_page.dart';
import '../../utils/menu/circle_nav_bar.dart';
import '../../widgets/common/custom_dialog.dart';
import 'zip_code_dialog.dart';

class PersonalProtectionGrid extends StatefulWidget {
  const PersonalProtectionGrid({super.key});

  @override
  State<PersonalProtectionGrid> createState() => _PersonalProtectionGridState();
}

class _PersonalProtectionGridState extends State<PersonalProtectionGrid> {
  int _selectedIndex = 1; // Inicializado en 1 para 'Add Insurance'
  final LocationService _locationService = LocationService();
  bool _isProcessingPersonalProtection =
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
              context.translate('personalProtection.back'),
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
                  context.translate('personalProtection.title'),
                  style: TextStyle(
                    color: AppTheme.getTitleTextColor(context),
                    fontSize: responsiveFontSizes.titleSmall(context),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: textScale.scale(1) > 1.5 ? 2 : 3,
                mainAxisSpacing: textScale.scale(1) > 1.5 ? 20.0 : 16.0,
                crossAxisSpacing: textScale.scale(1) > 1.5 ? 20.0 : 16.0,
                childAspectRatio: textScale.scale(1) > 2
                    ? 0.65
                    : textScale.scale(1) > 1.5
                        ? 0.8
                        : 0.9,
                children: [
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.health'),
                    'health_insurance',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.dental'),
                    'dental_insurance',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.telemedicine'),
                    'telemedicine',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.pet'),
                    'pet_insurance',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.life'),
                    'life_insurance',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.accidentalDeath'),
                    'travel_club_add',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.identityTheft'),
                    'identity_theft_protection',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.mexicanCar'),
                    'mexican_car_insurance',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('personalProtection.hospitalIndemnity'),
                    'hospital_indemnity',
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
    // Ajustar el tamaño de fuente basado en el ancho disponible
    final fontSize = responsiveFontSizes.labelMedium(context);

    return GestureDetector(
      onTap: () {
        // Evitar múltiples llamadas mientras se procesa una solicitud
        if (!_isProcessingPersonalProtection) {
          // Determinar qué tipo de seguro se ha seleccionado
          if (title == context.translate('personalProtection.health')) {
            _handleHealthInsurance(context);
          } else if (title == context.translate('personalProtection.dental')) {
            _handleDentalInsurance(context);
          } else if (title ==
              context.translate('personalProtection.telemedicine')) {
            _handleTelemedicine(context);
          } else if (title == context.translate('personalProtection.pet')) {
            _handlePetInsurance(context);
          } else if (title == context.translate('personalProtection.life')) {
            _handleLifeInsurance(context);
          } else if (title ==
              context.translate('personalProtection.accidentalDeath')) {
            _handleAccidentalDeath(context);
          } else if (title ==
              context.translate('personalProtection.identityTheft')) {
            _handleIdentityTheft(context);
          } else if (title ==
              context.translate('personalProtection.mexicanCar')) {
            // Mostrar mensaje de que no está disponible actualmente
            _handleMexicanCarInsurance(context);
          } else if (title ==
              context.translate('personalProtection.hospitalIndemnity')) {
            _handleHospitalIndemnity(context);
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
                'assets/products/personalpng/4.0x/$iconName.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.health_and_safety,
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
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
      _isProcessingPersonalProtection = true;
    });

    // Mostrar un indicador de progreso
    final overlay = LoadingView.showOverlay(
      context,
      message: context.translate('personalProtection.processing'),
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
          _isProcessingPersonalProtection = false;
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
          _isProcessingPersonalProtection = false;
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
        _isProcessingPersonalProtection = false;
      });
    }
  }

  // Métodos específicos para cada tipo de seguro
  Future<void> _handleHealthInsurance(BuildContext context) async {
    await _handleInsurance(context, 'health_insurance');
  }

  Future<void> _handleDentalInsurance(BuildContext context) async {
    await _handleInsurance(context, 'dental_insurance');
  }

  Future<void> _handleTelemedicine(BuildContext context) async {
    await _handleInsurance(context, 'telemedicine');
  }

  Future<void> _handlePetInsurance(BuildContext context) async {
    await _handleInsurance(context, 'pet_insurance');
  }

  Future<void> _handleLifeInsurance(BuildContext context) async {
    await _handleInsurance(context, 'life_insurance');
  }

  Future<void> _handleAccidentalDeath(BuildContext context) async {
    await _handleInsurance(context, 'travel_club_add');
  }

  Future<void> _handleIdentityTheft(BuildContext context) async {
    await _handleInsurance(context, 'identity_theft_protection');
  }

  Future<void> _handleMexicanCarInsurance(BuildContext context) async {
    await _handleInsurance(context, 'mexican_car_insurance');
  }

  Future<void> _handleHospitalIndemnity(BuildContext context) async {
    await _handleInsurance(context, 'hospital_indemnity');
  }

  // Método para mostrar mensaje cuando un seguro no está disponible
  void _showNotAvailableMessage(BuildContext context, String insuranceType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$insuranceType ${context.translate('personalProtection.notAvailableMessage')}',
        ),
        backgroundColor: AppTheme.getOrangeColor(context),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      _isProcessingPersonalProtection = false;
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
              context.translate('personalProtection.location.invalidZipCode'),
            ),
            backgroundColor: AppTheme.getRedColor(context),
          ),
        );
      }
    }

    // Restablecer la bandera después de completar el proceso
    setState(() {
      _isProcessingPersonalProtection = false;
    });
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
        final date = user.nextPayment;
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
        title: context.translate('personalProtection.location.webDialogTitle'),
        message: context
            .translate('personalProtection.location.webDialogMessage')
            .replaceAll('{0}', placeName)
            .replaceAll('{1}', stateAbbreviation),
        positiveButtonText:
            context.translate('personalProtection.location.visitWebsite'),
        negativeButtonText:
            context.translate('personalProtection.location.cancel'),
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
        case 'health_insurance':
          urlString =
              'https://www.freeway.com/health-quote-form/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('personalProtection.health')} - $placeName, $stateAbbreviation';
          break;
        case 'dental_insurance':
          urlString =
              'https://www.freeway.com/dental-insurance-quote/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('personalProtection.dental')} - $placeName, $stateAbbreviation';
          break;
        case 'telemedicine':
          urlString =
              'https://buy.freeway.com/product/telemedicine/step-2#form__step_2';
          title = context.translate('personalProtection.telemedicine');
          break;
        case 'pet_insurance':
          urlString =
              'https://www.freeway.com/pet-insurance-quote/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('personalProtection.pet')} - $placeName, $stateAbbreviation';
          break;
        case 'life_insurance':
          urlString =
              'https://www.freeway.com/life-insurance-quote-form/?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title =
              '${context.translate('personalProtection.life')} - $placeName, $stateAbbreviation';
          break;
        case 'travel_club_add':
          urlString =
              'https://buy.freeway.com/product/ad-d/step-2?#form__step_2';
          title = context.translate('personalProtection.accidentalDeath');
          break;
        case 'identity_theft_protection':
          urlString =
              'https://buy.freeway.com/product/identity-theft/step-2#form__step_2';
          title = context.translate('personalProtection.identityTheft');
          break;
        case 'mexican_car_insurance':
          urlString = 'https://quote.sanborns.com/guest/fastquote/77001';
          title = context.translate('personalProtection.mexicanCar');
          break;
        case 'hospital_indemnity':
          urlString =
              'https://buy.freeway.com/product/hospital-indemnity/step-2?#form__step_2';
          title = context.translate('personalProtection.hospitalIndemnity');
          break;
        default:
          urlString = 'https://www.freeway.com/';
          title = context.translate('personalProtection.title');
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
