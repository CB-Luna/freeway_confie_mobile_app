import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freeway_app/locatordevice/presentation/controllers/location_controller.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/location_error_view.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/map_buttons.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/office_list.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/zip_code_input_view.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';
import 'package:freeway_app/widgets/homepage/header_section.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationDetailsViewV2 extends StatelessWidget {
  const LocationDetailsViewV2({super.key});

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
      child: const LocationDetailsViewV2Content(),
    );
  }
}

class LocationDetailsViewV2Content extends StatefulWidget {
  const LocationDetailsViewV2Content({super.key});

  @override
  State<LocationDetailsViewV2Content> createState() =>
      _LocationDetailsViewV2ContentState();
}

class _LocationDetailsViewV2ContentState
    extends State<LocationDetailsViewV2Content> {
  // Valores para el DraggableScrollableSheet
  // Estos son valores por defecto que pueden ser ajustados según el tamaño de la pantalla
  final double _minChildSize = 0.1;
  final double _maxChildSize = 0.8;

  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _mapReady = false;

  // Marcadores para la posición actual y la posición seleccionada
  List<Marker> _markers = [];

  // Posición inicial del mapa (se actualizará con la posición real)
  LatLng _initialPosition =
      const LatLng(25.6866, -100.3161); // Monterrey como fallback
  double _initialZoom = 13.0;
  //LatLng? _pendingCameraMove;

  // Posición actual del usuario (para calcular la distancia)
  LatLng? _userPosition;

  // Posición seleccionada manualmente (si existe)
  LatLng? _selectedPosition;

  // Distancia máxima permitida en metros
  final double _maxDistanceAllowed = 16093.4; // 10 millas

  @override
  void initState() {
    super.initState();

    // Asignar el controlador local al controlador del LocationController
    // para asegurar que siempre haya un controlador válido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller =
            Provider.of<LocationController>(context, listen: false);
        controller.mapController = _mapController;
        debugPrint(
          'DEBUG: Controlador local asignado al LocationController en V2',
        );
      }
    });

    // Ya no dependemos de coordenadas iniciales proporcionadas como propiedades
    // sino que las obtendremos del controlador

    _getCurrentLocation();
  }

  // Método para obtener la ubicación actual
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Los permisos de ubicación son requeridos para la creación del reporte',
        );
      }

      // Obtener la posición actual
      _currentPosition = await Geolocator.getCurrentPosition();

      final latLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      // Guardar la posición del usuario
      _userPosition = latLng;

      // Si no hay un marcador manual, usar la ubicación del usuario como posición inicial
      if (_selectedPosition == null) {
        _initialPosition = latLng;
        _selectedPosition = null;
      }

      // Actualizar los marcadores
      _updateMarkers();

      // Si el mapa está listo y no hay un marcador manual, centrar en la ubicación del usuario
      if (_mapReady && _selectedPosition == null) {
        _mapController.move(latLng, _initialZoom);
      }

      // Obtener la dirección a partir de las coordenadas
      await _getAddressFromLatLng(
        _selectedPosition != null && _selectedPosition != null
            ? _selectedPosition!
            : latLng,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Método para obtener la dirección a partir de coordenadas
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        setState(() {
          _isLoading = false;
        });

        debugPrint(
          'Selected Address: ${place.toString()} / LatLng: ${position.latitude}, ${position.longitude}',
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Address not found');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error al obtener la dirección: $e');
    }
  }

  // Remover el marcador manual y volver a la ubicación del usuario
  void _removeManualMarker() {
    setState(() {
      _selectedPosition = null;

      if (_userPosition != null) {
        _initialPosition = _userPosition!;
      }

      _updateMarkers();
    });

    if (_mapReady && _userPosition != null) {
      _mapController.move(_userPosition!, _initialZoom);
    }
  }

  // Actualizar los marcadores en el mapa
  void _updateMarkers() {
    _markers = [];

    // Añadir marcador de la ubicación del usuario si está disponible
    if (_userPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _userPosition!,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  context.translate('home.navigation.location'),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              Icon(
                Icons.person_pin_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ],
          ),
        ),
      );
    }

    // Añadir marcador de la ubicación seleccionada si existe
    if (_selectedPosition != null && _selectedPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _selectedPosition!,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  'Ubicación seleccionada',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ],
          ),
        ),
      );
    }
  }

  // La función _calculateRadiusInPixels se ha movido al controlador

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
          backgroundColor: AppTheme.getBackgroundColor(context),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: const HeaderSection(),
            ),
          ),
          body: _hasError
              ? _buildErrorView()
              : _isLoading
                  ? _buildLoadingView()
                  : _buildBody(context, controller),
          bottomNavigationBar: CircleNavBar(
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
        );
      },
    );
  }

  Widget _buildErrorView() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Error de ubicación', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                'Reintentar',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [LoadingView(message: 'Obteniendo tu ubicación...')],
      ),
    );
  }

  Widget _buildBody(BuildContext context, LocationController controller) {
    if (controller.state.isLoading) {
      return LoadingView(message: context.translate('common.loadingGif'));
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
          child: FlutterMap(
            key: ValueKey(
              'map-${state.searchRadiusInMiles}',
            ), // Clave única para forzar reconstrucción completa
            options: MapOptions(
              initialCenter: LatLng(
                state.currentPosition?.latitude ?? 32.715738,
                state.currentPosition?.longitude ?? -117.161084,
              ),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Evitar usar subdomains con OSM como recomiendan en la advertencia
                // subdomains: const ['a', 'b', 'c'],
                // Agregar userAgentPackageName para identificar la aplicació
                userAgentPackageName: 'com.example.confieapp',
              ),
              // Agregar marcadores si existen
              if (state.markers.isNotEmpty)
                MarkerLayer(
                  markers: state.markers.toList(),
                ),
            ],
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
    final theme = Theme.of(context);

    final state = controller.state;

    // Obtener el tamaño de la pantalla para cálculos responsive
    final screenSize = MediaQuery.of(context).size;
    final isShortScreen = screenSize.height < 700;

    // Ajustar los tamaños del DraggableScrollableSheet según el tamaño de la pantalla
    final minChildSize = isShortScreen ? 0.08 : _minChildSize;
    final initialSizeNoOffices = isShortScreen ? 0.3 : 0.45;
    final initialSizeWithOffices = isShortScreen ? 0.25 : 0.35;
    final maxChildSize = isShortScreen ? 0.7 : _maxChildSize;
    final DraggableScrollableController scrollController =
        DraggableScrollableController();

    // Ajustar los snapSizes para pantallas pequeñas
    final List<double> snapSizes = isShortScreen
        ? [minChildSize, 0.3, 0.45, maxChildSize]
        : [_minChildSize, 0.35, 0.5, _maxChildSize];

    return Stack(
      children: [
        Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: _initialZoom,
                maxZoom: 18.0,
                minZoom:
                    5.0, // Limitar el zoom mínimo para mantener el contexto local
                onMapReady: () {
                  setState(() {
                    _mapReady = true;
                  });
                  // Si hay un movimiento de cámara pendiente, ejecutarlo ahora
                  /* if (_pendingCameraMove != null) {
                    _mapController.move(_pendingCameraMove!, 18.0);
                    _pendingCameraMove = null;
                  } */
                },
                onPositionChanged: (camera, hasGesture) {
                  setState(() {
                    _initialZoom = camera.zoom;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Evitar usar subdomains con OSM como recomiendan en la advertencia
                  // subdomains: const ['a', 'b', 'c'],
                  // Agregar userAgentPackageName para identificar la aplicació
                  userAgentPackageName: 'com.example.confieapp',
                ),
                // Agregar marcadores si existen
                if (state.markers.isNotEmpty)
                  MarkerLayer(
                    markers: state.markers.toList(),
                  ),
                // Círculo que muestra el área permitida
                if (_userPosition != null)
                  CircleLayer(
                    // Agregar key única para forzar reconstrucción cuando cambia el radio
                    key: ValueKey(
                      'user-circle-$_maxDistanceAllowed-$_initialZoom',
                    ),
                    circles: [
                      CircleMarker(
                        point: _userPosition!,
                        radius: state.searchRadiusInMiles * 1609.34,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderColor: theme.colorScheme.primary,
                        borderStrokeWidth: 2.0,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: theme.colorScheme.secondary,
                child: const Icon(Icons.my_location),
              ),
            ),
            // Mostrar el botón de remover marcador solo cuando hay un marcador manual
            if (_selectedPosition != null)
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton(
                  onPressed: _removeManualMarker,
                  backgroundColor: theme.colorScheme.error,
                  tooltip: 'Remove marker',
                  child: const Icon(Icons.clear),
                ),
              ),
          ],
        ),

        // Botones para controlar el mapa
        MapButtons(
          onLocationPressed: () => controller.updateMapPosition(),
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
          controller: scrollController,
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
                // Expandir la lista para mostrar la oficina seleccionada
                scrollController.animateTo(
                  isShortScreen
                      ? 0.35
                      : 0.45, // Usar un tamaño que permita ver el contenido
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              showNoNearbyOfficesView: showNoNearbyOfficesView,
              onExpandSearchRadius: () {
                controller.expandSearchRadius(context, _maxDistanceAllowed);
                // Mantener la lista expandida después de expandir el radio
                scrollController.animateTo(
                  isShortScreen ? 0.25 : 0.35,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onViewAllOffices: () {
                controller.showAllOffices();
                // Colapsar parcialmente la lista al mostrar todas las oficinas
                scrollController.animateTo(
                  isShortScreen ? 0.35 : 0.45,
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
