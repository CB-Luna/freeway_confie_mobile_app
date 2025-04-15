import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../utils/menu/circle_nav_bar.dart';
import '../../../widgets/homepage/header_section.dart';
import '../controllers/location_controller.dart';
import '../widgets/loading_view.dart';
import '../widgets/location_error_view.dart';
import '../widgets/map_buttons.dart';
import '../widgets/office_list.dart';
import '../widgets/zip_code_input_view.dart';

class LocationDetailsView extends StatelessWidget {
  const LocationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return Scaffold(
        body: Center(
          child: Text(context.translate('office.error')),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) {
        final controller = LocationController(
          getCurrentLocation: args['getCurrentLocation'],
          getOffices: args['getOffices'],
          deviceInfo: args['deviceInfo'],
        );

        // Inicializar después de crear el controller
        Future.microtask(() => controller.initialize());
        return controller;
      },
      child: const LocationDetailsViewContent(),
    );
  }
}

class LocationDetailsViewContent extends StatefulWidget {
  const LocationDetailsViewContent({super.key});

  @override
  State<LocationDetailsViewContent> createState() =>
      _LocationDetailsViewContentState();
}

class _LocationDetailsViewContentState
    extends State<LocationDetailsViewContent> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  // Valores para el DraggableScrollableSheet
  // Estos son valores por defecto que pueden ser ajustados según el tamaño de la pantalla
  final double _minChildSize = 0.1;
  final double _maxChildSize = 0.8;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleBottomSheet() {
    // Obtener el tamaño de la pantalla para cálculos responsive
    final screenSize = MediaQuery.of(context).size;
    final isShortScreen = screenSize.height < 700;

    // Ajustar los valores según el tamaño de la pantalla
    final minSize = isShortScreen ? 0.08 : _minChildSize;
    final midSize = isShortScreen ? 0.45 : 0.5;
    final threshold = isShortScreen ? 0.35 : 0.4;

    // Si está en la posición mínima o cerca de ella, expandirlo
    if (_scrollController.size <= minSize + 0.05) {
      _scrollController.animateTo(
        midSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Si está expandido, colapsarlo
    else if (_scrollController.size >= threshold) {
      _scrollController.animateTo(
        minSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // En posición intermedia, expandirlo
    else {
      _scrollController.animateTo(
        midSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla para cálculos responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isShortScreen = screenSize.height < 700;

    // Ajustar el padding superior según el tamaño de la pantalla
    final topPadding = isShortScreen ? 30.0 : 40.0;
    final appBarHeight = isShortScreen ? 63.0 : 73.0;

    return Consumer<LocationController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: const HeaderSection(),
            ),
          ),
          body: _buildBody(context, controller),
          bottomNavigationBar: Transform.translate(
            offset: const Offset(0, 0),
            child: CircleNavBar(
              selectedPos: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/add-insurance');
                }
              },
              tabItems: [
                TabData(
                  Icons.home_outlined,
                  isSmallScreen
                      ? '' // En pantallas pequeñas, no mostrar texto
                      : context.translate('home.navigation.myProducts'),
                ),
                TabData(
                  Icons.verified_user_outlined,
                  isSmallScreen
                      ? ''
                      : context.translate('home.navigation.addInsurance'),
                ),
                TabData(
                  Icons.location_on_outlined,
                  isSmallScreen
                      ? ''
                      : context.translate('home.navigation.location'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LocationController controller) {
    if (controller.state.isLoading) {
      return const LoadingView();
    }

    // Si no hay permisos de ubicación, validar si hay codigo postal buscado para mostrar la vista de entrada de código postal
    if (!controller.state.hasLocationPermission) {
      if (controller.state.hasSearchedByZipCode) {
        return _buildMainContent(context, controller);
      } else {
        return _buildNoPermissionContent(context, controller);
      }
    }

    if (controller.state.errorMessage != null) {
      return LocationErrorView(
        errorMessage: controller.state.errorMessage!,
        onRetry: () => controller.retry(),
      );
    }

    return _buildMainContent(context, controller);
  }

  // Widget para mostrar cuando no hay permisos de ubicación
  Widget _buildNoPermissionContent(
    BuildContext context,
    LocationController controller,
  ) {
    final state = controller.state;

    return Column(
      children: [
        // Mapa con ubicación por defecto (sin marcador de ubicación actual)
        Expanded(
          flex: 1,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                state.currentPosition?.latitude ?? 32.715738,
                state.currentPosition?.longitude ?? -117.161084,
              ),
              zoom: 10.0,
            ),
            markers: state.markers,
            circles: state.circles,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            trafficEnabled: false,
          ),
        ),
        // Vista de entrada de código postal
        ZipCodeInputView(
          onUseCurrentLocation: () {
            // Intentar solicitar permisos de ubicación nuevamente
            controller.requestLocationPermission();
          },
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    LocationController controller,
  ) {
    final state = controller.state;

    // Obtener el tamaño de la pantalla para cálculos responsive
    final screenSize = MediaQuery.of(context).size;
    final isShortScreen = screenSize.height < 700;

    // Ajustar los tamaños del DraggableScrollableSheet según el tamaño de la pantalla
    final minChildSize = isShortScreen ? 0.08 : _minChildSize;
    final initialSizeNoOffices = isShortScreen ? 0.3 : 0.35;
    final initialSizeWithOffices = isShortScreen ? 0.2 : 0.25;
    final maxChildSize = isShortScreen ? 0.7 : _maxChildSize;

    // Ajustar los snapSizes para pantallas pequeñas
    final List<double> snapSizes = isShortScreen
        ? [minChildSize, 0.3, 0.45, maxChildSize]
        : [_minChildSize, 0.35, 0.5, _maxChildSize];

    return Stack(
      children: [
        // Mapa con configuración optimizada para emuladores
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: state.currentPosition != null
                ? LatLng(
                    state.currentPosition!.latitude,
                    state.currentPosition!.longitude,
                  )
                : const LatLng(32.715738, -117.161084), // San Diego por defecto
            zoom: 14.0,
          ),
          myLocationEnabled:
              false, // Desactivamos porque usamos un marcador personalizado
          myLocationButtonEnabled: false,
          markers: state.markers,
          circles: state.circles, // Agregamos los círculos de cobertura
          onMapCreated: (GoogleMapController mapController) {
            controller.onMapCreated(mapController);
          },
          zoomControlsEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          trafficEnabled: false, // Desactivar tráfico para mejor rendimiento
        ),

        // Botones para controlar el mapa
        MapButtons(
          onLocationPressed: () => controller.updateMapPosition(),
          onToggleListPressed: _toggleBottomSheet,
        ),

        // Lista de oficinas
        DraggableScrollableSheet(
          // Ajustar el tamaño inicial según si se muestra el mensaje de no hay oficinas cercanas
          initialChildSize:
              !controller.hasNearbyOffices() && !state.showAllOffices
                  ? initialSizeNoOffices
                  : initialSizeWithOffices,
          minChildSize: minChildSize,
          // Aumentar el tamaño máximo para mostrar todo el contenido
          maxChildSize: maxChildSize,
          controller: _scrollController,
          // Añadir snap para que se ajuste a posiciones específicas
          snap: true,
          snapSizes: snapSizes,
          builder: (context, scrollController) {
            // Obtener la lista de oficinas a mostrar (cercanas o todas)
            final officesToDisplay = controller.getOfficeListToDisplay();
            // Verificar si hay oficinas cercanas
            final hasNearbyOffices = controller.hasNearbyOffices();
            // Mostrar el mensaje de no hay oficinas cercanas solo si no hay oficinas cercanas
            // y no estamos mostrando todas las oficinas
            final showNoNearbyOfficesView =
                !hasNearbyOffices && !state.showAllOffices;

            return OfficeList(
              offices: officesToDisplay,
              scrollController: scrollController,
              onOfficeTap: (office) {
                // Usar navigateToOffice para centrar la vista en la oficina seleccionada
                controller.navigateToOffice(office);
                // Colapsar la lista al mínimo cuando se selecciona una oficina
                _scrollController.animateTo(
                  minChildSize,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              showNoNearbyOfficesView: showNoNearbyOfficesView,
              onExpandSearchRadius: () {
                controller.expandSearchRadius(context);
                // Mantener la lista expandida después de expandir el radio
                _scrollController.animateTo(
                  isShortScreen ? 0.3 : 0.35,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onViewAllOffices: () {
                controller.showAllOffices();
                // Colapsar parcialmente la lista al mostrar todas las oficinas
                _scrollController.animateTo(
                  isShortScreen ? 0.2 : 0.25,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
