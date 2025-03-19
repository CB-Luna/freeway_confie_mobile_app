import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../utils/menu/circle_nav_bar.dart';
import '../../../widgets/homepage/header_section.dart';
import '../controllers/location_controller.dart';
import '../widgets/loading_view.dart';
import '../widgets/location_error_view.dart';
import '../widgets/map_buttons.dart';
import '../widgets/office_list.dart';
import '../widgets/simulator_banner.dart';

class LocationDetailsView extends StatelessWidget {
  const LocationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Missing dependencies'),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleBottomSheet() {
    if (_scrollController.size <= 0.25) {
      _scrollController.animateTo(
        0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.animateTo(
        0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(73),
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: HeaderSection(),
            ),
          ),
          body: _buildBody(context, controller),
          bottomNavigationBar: Transform.translate(
            offset: const Offset(0, -20),
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
                TabData(Icons.home_outlined, 'My Products'),
                TabData(Icons.verified_user_outlined, '+ Add Insurance'),
                TabData(Icons.location_on_outlined, 'Location'),
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

    if (controller.state.errorMessage != null) {
      return LocationErrorView(
        errorMessage: controller.state.errorMessage!,
        onRetry: () => controller.retry(),
      );
    }

    return _buildMainContent(context, controller);
  }

  Widget _buildMainContent(
    BuildContext context,
    LocationController controller,
  ) {
    final state = controller.state;

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
          liteModeEnabled: defaultTargetPlatform == TargetPlatform.android &&
              state
                  .isEmulatorOrSimulator, // Usar lite mode solo en emuladores Android
          trafficEnabled: false, // Desactivar tráfico para mejor rendimiento
        ),

        // Botones para controlar el mapa
        MapButtons(
          onLocationPressed: () => controller.updateMapPosition(),
          onToggleListPressed: _toggleBottomSheet,
        ),

        // Banner de simulador/emulador
        if (state.isEmulatorOrSimulator)
          SimulatorBanner(
            onClose: () => controller.setEmulatorMode(false),
          ),

        // Lista de oficinas
        DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.1,
          maxChildSize: 0.6,
          controller: _scrollController,
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
                controller.goToOffice(office);
                _scrollController.animateTo(
                  0.1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              showNoNearbyOfficesView: showNoNearbyOfficesView,
              onExpandSearchRadius: () => controller.expandSearchRadius(),
              onViewAllOffices: () => controller.showAllOffices(),
            );
          },
        ),
      ],
    );
  }
}
