import 'package:flutter/material.dart';
import 'package:freeway_app/data/constants.dart';
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

class AdditionalProductsGrid extends StatefulWidget {
  const AdditionalProductsGrid({super.key});

  @override
  State<AdditionalProductsGrid> createState() => _AdditionalProductsGridState();
}

class _AdditionalProductsGridState extends State<AdditionalProductsGrid> {
  int _selectedIndex = 1; // Inicializado en 1 para 'Add Insurance'
  final LocationService _locationService = LocationService();
  bool _isProcessingAdditionalProducts =
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
              context.translate('additionalProducts.back'),
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
                  context.translate('additionalProducts.title'),
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
                    context.translate('additionalProducts.autoClub'),
                    'auto_club',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.windshieldRepair'),
                    'windshield_repair',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.vrrOnlineCalifornia'),
                    'vrr_online_california',
                  ),
                  _buildInsuranceItem(
                    context,
                    context
                        .translate('additionalProducts.tireHazardProtection'),
                    'tire_hazard_protection',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.dentRepair'),
                    'dent_repair',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.petHealth'),
                    'pet_health',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.autoLoan'),
                    'auto_loan',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.taxPreparation'),
                    'tax_preparation',
                  ),
                  _buildInsuranceItem(
                    context,
                    context.translate('additionalProducts.oneStopDui'),
                    'one_stop_dui',
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
    final fontSize = responsiveFontSizes.labelMedium(context);

    return GestureDetector(
      onTap: () {
        // Evitar múltiples llamadas mientras se procesa una solicitud
        if (!_isProcessingAdditionalProducts) {
          // Determinar qué tipo de seguro se ha seleccionado
          if (title == context.translate('additionalProducts.autoClub')) {
            _handleAutoClub(context);
          } else if (title ==
              context.translate('additionalProducts.windshieldRepair')) {
            _handleWindshieldRepair(context);
          } else if (title ==
              context.translate('additionalProducts.vrrOnlineCalifornia')) {
            _handleVrrOnlineCalifornia(context);
          } else if (title ==
              context.translate('additionalProducts.tireHazardProtection')) {
            _handleTireHazardProtection(context);
          } else if (title ==
              context.translate('additionalProducts.dentRepair')) {
            _handleDentRepair(context);
          } else if (title ==
              context.translate('additionalProducts.petHealth')) {
            _handlePetHealth(context);
          } else if (title ==
              context.translate('additionalProducts.autoLoan')) {
            _handleAutoLoan(context);
          } else if (title ==
              context.translate('additionalProducts.taxPreparation')) {
            _handleTaxPreparation(context);
          } else if (title ==
              context.translate('additionalProducts.oneStopDui')) {
            _handleOneStopDui(context);
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
                'assets/products/additionalpng/4.0x/$iconName.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.add_circle_outline,
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
      _isProcessingAdditionalProducts = true;
    });

    // Mostrar un indicador de progreso
    final overlay = LoadingView.showOverlay(
      context,
      message: context.translate('additionalProducts.processing'),
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
          _isProcessingAdditionalProducts = false;
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
          _isProcessingAdditionalProducts = false;
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
        _isProcessingAdditionalProducts = false;
      });
    }
  }

  // Métodos específicos para cada tipo de seguro
  Future<void> _handleAutoClub(BuildContext context) async {
    await _handleInsurance(context, 'auto_club');
  }

  Future<void> _handleWindshieldRepair(BuildContext context) async {
    await _handleInsurance(context, 'windshield_repair');
  }

  Future<void> _handleVrrOnlineCalifornia(BuildContext context) async {
    await _handleInsurance(context, 'vrr_online_california');
  }

  Future<void> _handleTireHazardProtection(BuildContext context) async {
    await _handleInsurance(context, 'tire_hazard_protection');
  }

  Future<void> _handleDentRepair(BuildContext context) async {
    await _handleInsurance(context, 'dent_repair');
  }

  Future<void> _handlePetHealth(BuildContext context) async {
    await _handleInsurance(context, 'pet_health');
  }

  Future<void> _handleAutoLoan(BuildContext context) async {
    await _handleInsurance(context, 'auto_loan');
  }

  Future<void> _handleTaxPreparation(BuildContext context) async {
    await _handleInsurance(context, 'tax_preparation');
  }

  Future<void> _handleOneStopDui(BuildContext context) async {
    await _handleInsurance(context, 'one_stop_dui');
  }

  // Método para mostrar mensaje cuando un seguro no está disponible
  void _showNotAvailableMessage(BuildContext context, String insuranceType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$insuranceType ${context.translate('additionalProducts.notAvailableMessage')}',
        ),
        backgroundColor: AppTheme.getOrangeColor(context),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      _isProcessingAdditionalProducts = false;
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
              context.translate('additionalProducts.location.invalidZipCode'),
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
        title: context.translate('additionalProducts.location.webDialogTitle'),
        message: context
            .translate('additionalProducts.location.webDialogMessage')
            .replaceAll('{0}', placeName)
            .replaceAll('{1}', stateAbbreviation),
        positiveButtonText:
            context.translate('additionalProducts.location.visitWebsite'),
        negativeButtonText:
            context.translate('additionalProducts.location.cancel'),
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
        case 'auto_club':
          urlString = '${urlBaseEmbed}insurance-options/auto-club/';
          title = context.translate('additionalProducts.autoClub');
          break;
        case 'windshield_repair':
          urlString =
              '${urlBaseEmbedBuyProduct}product/windshield-repair/step-1?';
          title = context.translate('additionalProducts.windshieldRepair');
          break;
        case 'vrr_online_california':
          urlString =
              '${urlBaseEmbedCarRegistration}freeway?affid=FWAY&cid=web&utm=&utm_source=FreeWay-Insurance&utm_medium=web&utm_campaign=Freeway&utm_id=Freeway+Insurance&utm_term=web';
          title = context.translate('additionalProducts.vrrOnlineCalifornia');
          break;
        case 'tire_hazard_protection':
          urlString =
              '${urlBaseEmbedBuyProduct}product/paintless-dent-repair/step-1';
          title = context.translate('additionalProducts.tireHazardProtection');
          break;
        case 'dent_repair':
          urlString =
              '${urlBaseEmbedBuyProduct}product/paintless-dent-repair/step-1';
          title = context.translate('additionalProducts.dentRepair');
          break;
        case 'pet_health':
          urlString =
              '${urlBaseEmbed}insurance-options/pet-health-and-discount-services/';
          title = context.translate('additionalProducts.petHealth');
          break;
        case 'auto_loan':
          urlString =
              '$urlBaseEmbedTriton?media_code=FWYCA-A-WW-WS-E-05884&phone=877-699-2436&?zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title = context.translate('additionalProducts.autoLoan');
          break;
        case 'tax_preparation':
          urlString =
              '$urlBaseEmbedTaxmax/TaxCalculation/ExtLand.aspx?type=confie&id=97265a19-8630-44e4-a427-d476ef0d33cd';
          title = context.translate('additionalProducts.taxPreparation');
          break;
        case 'one_stop_dui':
          urlString =
              '$urlBaseEmbedTriton?media_code=FWYCA-A-WW-WS-E-05884&phone=877-699-2436&zipcode=$zipCode&state=$stateAbbreviation&city=${Uri.encodeComponent(placeName)}';
          title = context.translate('additionalProducts.oneStopDui');
          break;
        default:
          urlString = urlBaseEmbed;
          title = context.translate('additionalProducts.title');
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
