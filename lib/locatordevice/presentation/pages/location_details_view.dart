import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/location_controller.dart';
import '../widgets/loading_view.dart';
import '../widgets/location_error_view.dart';
import '../widgets/map_buttons.dart';
import '../widgets/office_list.dart';
import '../widgets/simulator_banner.dart';

class LocationDetailsView extends StatefulWidget {
  const LocationDetailsView({super.key});

  @override
  State<LocationDetailsView> createState() => _LocationDetailsViewState();
}

class _LocationDetailsViewState extends State<LocationDetailsView> {
  late LocationController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (!mounted) return;
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      throw Exception('Missing dependencies');
    }

    _controller = LocationController(
      getCurrentLocation: args['getCurrentLocation'],
      getOffices: args['getOffices'],
      deviceInfo: args['deviceInfo'],
    );

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      await _controller.initialize();
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: LoadingView(),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
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

class _LocationDetailsViewContentState extends State<LocationDetailsViewContent> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();
      
  // Estilo básico del mapa para Android
  static const String _mapStyle = '''
    [
      {
        "featureType": "all",
        "elementType": "all",
        "stylers": [
          {
            "visibility": "on"
          }
        ]
      }
    ]
  ''';

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
          appBar: AppBar(
            title: const Text('Nearby Locations'),
            elevation: 0,
            actions: [
              if (controller.state.isEmulatorOrSimulator)
                IconButton(
                  icon: const Icon(Icons.location_searching),
                  tooltip: 'Cambiar ubicación simulada',
                  onPressed: () => _showLocationDialog(context, controller),
                ),
            ],
          ),
          body: _buildBody(context, controller),
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
      BuildContext context, LocationController controller,) {
    final state = controller.state;

    return Stack(
      children: [
        // Mapa
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: state.currentPosition != null
                ? LatLng(
                    state.currentPosition!.latitude,
                    state.currentPosition!.longitude,
                  )
                : const LatLng(0, 0),
            zoom: 14.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: state.markers,
          onMapCreated: controller.onMapCreated,
          liteModeEnabled: defaultTargetPlatform == TargetPlatform.android,
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          compassEnabled: true,
          style: defaultTargetPlatform == TargetPlatform.android ? _mapStyle : null,
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
            return OfficeList(
              offices: state.offices,
              scrollController: scrollController,
              onOfficeTap: (office) {
                controller.goToOffice(office);
                _scrollController.animateTo(
                  0.1,
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

  void _showLocationDialog(
      BuildContext context, LocationController controller,) {
    // Coordenadas de San Diego
    const double sandiegoLat = 32.715738;
    const double sandiegoLng = -117.161084;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Establecer ubicación personalizada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona una ubicación cercana a las oficinas:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('San Diego (cerca de las oficinas)'),
              onTap: () {
                controller.setCustomLocation(sandiegoLat, sandiegoLng);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Usar ubicación del emulador'),
              onTap: () {
                controller.retry();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
