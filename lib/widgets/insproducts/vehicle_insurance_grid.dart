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
              context.translate('vehicleInsurance.back'),
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
                  context.translate('vehicleInsurance.title'),
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
                crossAxisCount: textScale.scale(1) > 2.5
                    ? 1
                    : textScale.scale(1) > 1.5
                        ? 2
                        : 3,
                mainAxisSpacing: textScale.scale(1) > 2.5
                    ? 20.0
                    : textScale.scale(1) > 1.5
                        ? 18.0
                        : 10.0,
                crossAxisSpacing: textScale.scale(1) > 2.5
                    ? 20.0
                    : textScale.scale(1) > 1.5
                        ? 18.0
                        : 10.0,
                childAspectRatio: textScale.scale(1) > 2.5
                    ? 0.4
                    : textScale.scale(1) > 1.5
                        ? 0.65
                        : 0.7,
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
                    'rv_motorhome',
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
                    'sr_22',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('vehicleInsurance.classicCar'),
                    'classic_car',
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
        if (!_isProcessingAutoInsurance) {
          // Determinar qué tipo de seguro se ha seleccionado
          if (title == context.translate('vehicleInsurance.auto')) {
            _handleAutoInsurance(context);
          } else if (title ==
              context.translate('vehicleInsurance.motorcycle')) {
            _handleMotorcycleInsurance(context);
          } else if (title == context.translate('vehicleInsurance.motorhome')) {
            _handleMotorhomeInsurance(context);
          } else if (title ==
              context.translate('vehicleInsurance.rvMotorhome')) {
            _handleRVMotorhomeInsurance(context);
          } else if (title ==
              context.translate('vehicleInsurance.snowmobile')) {
            _handleSnowmobileInsurance(context);
          } else if (title ==
              context.translate('vehicleInsurance.classicCar')) {
            _handleClassicCarInsurance(context);
          } else if (title ==
              context.translate('vehicleInsurance.sr22Insurance')) {
            _handleSR22Insurance(context);
          } else if (title == context.translate('vehicleInsurance.atv')) {
            // Mostrar mensaje de que no está disponible actualmente
            _showNotAvailableMessage(context, title);
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
                'assets/products/vehiclepng/4.0x/$iconName.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.car_rental,
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
      _isProcessingAutoInsurance = true;
    });

    // Mostrar un indicador de progreso
    final overlay = LoadingView.showOverlay(
      context,
      message: context.translate('vehicleInsurance.processing'),
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
          _isProcessingAutoInsurance = false;
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
          _isProcessingAutoInsurance = false;
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
        _isProcessingAutoInsurance = false;
      });
    }
  }

  // Métodos específicos para cada tipo de seguro
  Future<void> _handleAutoInsurance(BuildContext context) async {
    await _handleInsurance(context, 'auto');
  }

  Future<void> _handleMotorcycleInsurance(BuildContext context) async {
    await _handleInsurance(context, 'motorcycle');
  }

  Future<void> _handleMotorhomeInsurance(BuildContext context) async {
    await _handleInsurance(context, 'motorhome');
  }

  Future<void> _handleRVMotorhomeInsurance(BuildContext context) async {
    await _handleInsurance(context, 'rv_motorhome');
  }

  Future<void> _handleSnowmobileInsurance(BuildContext context) async {
    await _handleInsurance(context, 'snowmobile');
  }

  Future<void> _handleClassicCarInsurance(BuildContext context) async {
    await _handleInsurance(context, 'classic_car');
  }

  Future<void> _handleSR22Insurance(BuildContext context) async {
    await _handleInsurance(context, 'sr22');
  }

  // Método para mostrar mensaje cuando un seguro no está disponible
  void _showNotAvailableMessage(BuildContext context, String insuranceType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$insuranceType ${context.translate('vehicleInsurance.notAvailableMessage')}',
        ),
        backgroundColor: AppTheme.getOrangeColor(context),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      _isProcessingAutoInsurance = false;
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
      // Determinar la URL basada en el tipo de seguro
      String urlString;
      String title;

      // Añadir información del usuario a las URLs cuando sea posible
      final String firstName = userData['firstName'] ?? '';
      final String lastName = userData['lastName'] ?? '';
      final String email = userData['email'] ?? '';
      final String phone = userData['phone'] ?? '';

      switch (insuranceType) {
        case 'auto':
          urlString =
              'https://triton.freeway.com/?media_code=FWYCA-A-WW-WS-E-05884&phone=877-699-2436&zip_code=$zipCode&city=$placeName&state=$stateAbbreviation&system=atalaya&first_name=$firstName&last_name=$lastName&email=$email&phone_number=$phone';
          title =
              '${context.translate('vehicleInsurance.auto')} - $placeName, $stateAbbreviation';
          break;
        case 'motorcycle':
          urlString =
              'https://www.freewayseguros.com/cotizacion-seguro-de-moto/?zipcode=$zipCode&state=$stateAbbreviation&city=$placeName&first_name=$firstName&last_name=$lastName&email=$email&phone=$phone';
          title =
              '${context.translate('vehicleInsurance.motorcycle')} - $placeName, $stateAbbreviation';
          break;
        case 'motorhome':
          urlString =
              'https://www.freewayseguros.com/cotizacion-seguro-de-casa-rodante/?zipcode=$zipCode&state=$stateAbbreviation&city=$placeName&first_name=$firstName&last_name=$lastName&email=$email&phone=$phone';
          title =
              '${context.translate('vehicleInsurance.motorhome')} - $placeName, $stateAbbreviation';
          break;
        case 'rv_motorhome':
          urlString =
              'https://www.freewayseguros.com/cotizacion-seguro-de-casa-movil-y-casa-prefabricada/?zipCodeForm=$zipCode&first_name=$firstName&last_name=$lastName&email=$email&phone=$phone';
          title =
              '${context.translate('vehicleInsurance.rvMotorhome')} - $placeName, $stateAbbreviation';
          break;
        case 'snowmobile':
          urlString =
              'https://www.freewayseguros.com/cotizacion-seguro-para-moto-de-nieve/?zipcode=$zipCode&state=$stateAbbreviation&city=$placeName&first_name=$firstName&last_name=$lastName&email=$email&phone=$phone';
          title =
              '${context.translate('vehicleInsurance.snowmobile')} - $placeName, $stateAbbreviation';
          break;
        case 'classic_car':
          urlString =
              'https://triton.freeway.com/?first_name=$firstName&last_name=$lastName&email=$email&phone=$phone';
          title = context.translate('vehicleInsurance.classicCar');
          break;
        case 'sr22':
          urlString =
              'https://triton.freeway.com/?first_name=$firstName&last_name=$lastName&email=$email&phone=$phone';
          title = context.translate('vehicleInsurance.sr22Insurance');
          break;
        default:
          urlString =
              'https://triton.freeway.com/?media_code=FWYCA-A-WW-WS-E-05884&phone=877-699-2436&zip_code=$zipCode&city=$placeName&state=$stateAbbreviation&system=atalaya&first_name=$firstName&last_name=$lastName&email=$email&phone_number=$phone';
          title =
              '${context.translate('vehicleInsurance.auto')} - $placeName, $stateAbbreviation';
      }

      // Abrir la URL en un WebView embebido en lugar de un navegador externo
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            url: urlString,
            title: title,
            userData: userData, // Pasar los datos del usuario al WebView
            formType: insuranceType, // Pasar el tipo de formulario
          ),
        ),
      );
    }
  }
}
