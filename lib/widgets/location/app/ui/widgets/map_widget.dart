import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/office_location.dart';
import '../../domain/services/map_service.dart';
import '../controllers/map_style_controller.dart';
import '../controllers/marker_controller.dart';
import '../utils/snackbar_helper.dart';
import './google_map_view.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  GoogleMapController? mapController;
  bool _styleLoaded = false;
  bool _markerIconLoaded = false;
  bool _redArrowIconLoaded = false;
  bool _locationPermissionGranted = false;
  bool _initialLocationObtained = false;

  // Variables para el panel deslizable
  bool _showOfficePanel = false;
  OfficeLocation? _nearestOffice;
  double _userLatitude = 0;
  double _userLongitude = 0;

  // Indicador de carga para la obtención de la dirección
  bool _isLoadingAddress = false;
  bool _isLoadingCurrentLocation = true;

  // Dirección real obtenida de la API de geocodificación inversa
  String? _formattedAddress;

  // Dirección de ubicación actual
  String? _currentLocationAddress;

  // Controladores refactorizados
  final MapStyleController _styleController = MapStyleController();
  final MarkerController _markerController = MarkerController();
  // Servicio para obtener la dirección real
  final MapService _mapService = MapService();

  // Usaremos CameraPosition definida por la ubicación real, no una posición inicial fija
  CameraPosition? _initialCameraPosition;

  // Constante para la posición predeterminada (Tijuana)
  static const _defaultPosition = LatLng(32.5149, -117.0382);
  static const _defaultZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
    _loadRedArrowIcon();

    // Registramos los callbacks
    _markerController.setOnMarkerDraggedCallback(_notifyMarkerDragged);
    _markerController.setOnNearestOfficeFoundCallback(_showNearestOfficePanel);

    // Suscribirse a cambios de estilo
    _styleController.addListener(() {
      if (mounted) setState(() {});
    });

    // Verificar permisos y detectar ubicación actual al iniciar
    _initializeLocation();
  }

  // Método consolidado para inicializar la ubicación
  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      // Paso 1: Verificar los permisos de ubicación
      final hasPermission = await _mapService.checkLocationPermission();

      if (!mounted) return; // Comprobar si el widget sigue montado

      setState(() {
        _locationPermissionGranted = hasPermission;
      });

      // Paso 2: Obtener la ubicación si tenemos permisos
      if (_locationPermissionGranted) {
        await _getCurrentLocation(isInitial: true);
      } else {
        // Si no hay permisos, usar la posición predeterminada
        _setDefaultPosition();

        // Mostrar un mensaje al usuario
        if (mounted) {
          SnackbarHelper.showErrorSnackBar(
            context,
            'Se requieren permisos de ubicación para mostrar tu posición actual.',
            duration: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      debugPrint('Error inicializando ubicación: $e');

      // Si hay un error, usar la posición predeterminada
      _setDefaultPosition();
    }
  }

  // Método para establecer la posición predeterminada
  void _setDefaultPosition() {
    setState(() {
      _isLoadingCurrentLocation = false;
      _initialCameraPosition = const CameraPosition(
        target: _defaultPosition,
        zoom: _defaultZoom,
      );
      _initialLocationObtained =
          true; // Marcar como obtenida aunque sea predeterminada
    });
  }

  // Método optimizado para obtener la ubicación actual
  Future<void> _getCurrentLocation({bool isInitial = false}) async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      // Si es una solicitud no inicial y no tenemos permisos, intentar obtenerlos
      if (!isInitial && !_locationPermissionGranted) {
        final hasPermission = await _mapService.checkLocationPermission();

        setState(() {
          _locationPermissionGranted = hasPermission;
        });

        if (!hasPermission) {
          _setDefaultPosition();
          SnackbarHelper.showErrorSnackBar(
            context,
            'No se concedieron permisos de ubicación. Usando ubicación predeterminada.',
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      // Obtener ubicación actual usando el servicio
      final location = await _mapService.getCurrentLocation();
      final currentPosition = LatLng(location.latitude, location.longitude);

      // Añadir un marcador en la ubicación actual
      _markerController.addOrUpdateRedArrowMarker(currentPosition);

      // Actualizar las variables de ubicación
      setState(() {
        _userLatitude = location.latitude;
        _userLongitude = location.longitude;
      });

      // Configurar la cámara según sea una solicitud inicial o no
      if (isInitial) {
        setState(() {
          _initialCameraPosition = CameraPosition(
            target: currentPosition,
            zoom: 15,
          );
          _initialLocationObtained = true;
        });
      } else if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            currentPosition,
            15,
          ),
        );
      }

      // Obtener la dirección de la ubicación actual
      await _getAddressForCurrentLocation(
        location.latitude,
        location.longitude,
      );
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');

      if (isInitial) {
        _setDefaultPosition();
      }

      SnackbarHelper.showWarningSnackBar(
        context,
        'No se pudo obtener la ubicación actual. Usando ubicación predeterminada.',
      );

      setState(() {
        _isLoadingCurrentLocation = false;
      });
    }
  }

  // Método para obtener dirección desde coordenadas
  Future<void> _getAddressForCurrentLocation(double lat, double lng) async {
    if (!mounted) return;

    setState(() {
      _isLoadingAddress = true;
      _currentLocationAddress = null;
    });

    String address;
    try {
      address = await _mapService.getAddressFromCoordinates(lat, lng);
    } catch (e) {
      debugPrint('Error obteniendo dirección: $e');
      address = 'No se pudo determinar la dirección';
    }

    if (!mounted) return;

    setState(() {
      _currentLocationAddress = address;
      _isLoadingAddress = false;
      _isLoadingCurrentLocation = false;
    });
  }

  // Carga el icono personalizado para oficinas
  Future<void> _loadMarkerIcon() async {
    if (_markerIconLoaded) return;
    await _markerController.loadCustomMarker();
    if (mounted) {
      setState(() {
        _markerIconLoaded = true;
      });
    }
  }

  // Carga el icono de flecha roja
  Future<void> _loadRedArrowIcon() async {
    if (_redArrowIconLoaded) return;
    await _markerController.loadRedArrowIcon();
    if (mounted) {
      setState(() {
        _redArrowIconLoaded = true;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mapController != null) return; // Evitar reinicialización
    mapController = controller;
    _styleController.initMapController(controller);
    if (mounted) {
      setState(() {
        _styleLoaded = true;
      });
    }

    // Si ya tenemos una ubicación al crear el mapa, movernos a ella
    if (_userLatitude != 0 && _userLongitude != 0) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_userLatitude, _userLongitude),
          15,
        ),
      );
    }
  }

  // Método para cambiar el estilo del mapa
  void _changeMapStyle() {
    _styleController.changeMapStyle();
    setState(() {}); // Actualizar la UI para reflejar el nuevo tipo de mapa
  }

  // Método para activar/desactivar el modo de marcadores de oficina
  void _toggleMarkerMode() {
    final isActive = _markerController.toggleMarkerMode();

    setState(() {}); // Actualizar la UI

    SnackbarHelper.showBlueSnackBar(
      context,
      isActive
          ? 'Office marker mode activated - Tap the map to add draggable office markers'
          : 'Office marker mode deactivated',
    );
  }

  // Método para activar/desactivar el modo de marcador de flecha roja
  void _toggleRedArrowMode() {
    final isActive = _markerController.toggleRedArrowMode();

    setState(() {
      // Ocultar el panel si se desactiva el modo de flecha roja
      if (!isActive) {
        _showOfficePanel = false;
        _formattedAddress = null;
      }
    });

    SnackbarHelper.showBlueSnackBar(
      context,
      isActive
          ? 'Red arrow marker mode activated - Tap the map to place your location marker'
          : 'Red arrow marker mode deactivated',
    );
  }

  // Método para notificar cuando un marcador es arrastrado
  void _notifyMarkerDragged(String markerId, LatLng position) {
    SnackbarHelper.showBlueSnackBar(
      context,
      'Office marker moved to: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      duration: const Duration(seconds: 2),
    );
  }

  // Método actualizado para mostrar el panel de la oficina más cercana
  Future<void> _showNearestOfficePanel(
    OfficeLocation office,
    double userLat,
    double userLon,
  ) async {
    if (!mounted) return;

    setState(() {
      _nearestOffice = office;
      _userLatitude = userLat;
      _userLongitude = userLon;
      _showOfficePanel = true;
      _isLoadingAddress = true;
      _formattedAddress = null;
    });

    String address;
    try {
      address = await _mapService.getAddressFromCoordinates(
        office.latitude,
        office.longitude,
      );
    } catch (e) {
      debugPrint('Error obteniendo la dirección: $e');
      address = 'Dirección no disponible';
    }

    if (!mounted) return;

    setState(() {
      _formattedAddress = address;
      _isLoadingAddress = false;
    });
  }

  // Método para añadir un marcador dependiendo del modo activo
  void _handleMapTap(LatLng position) {
    // Modo de marcador de oficina
    if (_markerController.markerMode) {
      _markerController.addMarker(position);
      setState(() {}); // Actualizar la UI

      SnackbarHelper.showBlueSnackBar(
        context,
        'Added new office marker',
        duration: const Duration(seconds: 2),
      );
    }

    // Modo de marcador de flecha roja
    if (_markerController.redArrowMode) {
      _markerController.addOrUpdateRedArrowMarker(position);
      setState(() {
        _showOfficePanel = false; // Ocultar panel si se mueve el marcador
        _formattedAddress = null;
      }); // Actualizar la UI

      // Actualizar dirección para la nueva posición
      _getAddressForCurrentLocation(position.latitude, position.longitude);

      SnackbarHelper.showBlueSnackBar(
        context,
        'Added red location marker - Tap on it to find the nearest office',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Método para eliminar todos los marcadores
  void _clearMarkers() {
    _markerController.clearMarkers();
    setState(() {
      _showOfficePanel =
          false; // Ocultar el panel cuando se borran los marcadores
      _formattedAddress = null;
      _currentLocationAddress = null;
    }); // Actualizar la UI

    SnackbarHelper.showBlueSnackBar(
      context,
      'All markers have been cleared',
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga hasta que tengamos la ubicación y estilos cargados
    if (!_initialLocationObtained ||
        _initialCameraPosition == null ||
        !_markerIconLoaded ||
        !_redArrowIconLoaded) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Obteniendo tu ubicación...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GoogleMapView(
          onMapCreated: _onMapCreated,
          initialPosition: _initialCameraPosition!,
          markers: _markerController.getAllMarkers(),
          onTap: _handleMapTap,
          mapType: _styleController.currentMapType,
          customMapStyle: _styleController.currentCustomStyle,
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: false, // Usamos nuestro propio botón
        ),
        if (!_styleLoaded ||
            !_markerIconLoaded ||
            !_redArrowIconLoaded ||
            _isLoadingCurrentLocation)
          const Center(child: CircularProgressIndicator()),

        // Mostrar la dirección actual en la parte superior de la pantalla
        if (_currentLocationAddress != null && !_showOfficePanel)
          Positioned(
            top: 16,
            left: 16,
            right: 70, // Dejar espacio para los botones de la derecha
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ubicación actual:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0A4DA2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentLocationAddress!,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

        // Botones de control actualizados con el nuevo estilo
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              // Botón para obtener ubicación actual
              Tooltip(
                message: 'Obtener ubicación actual',
                child: FloatingActionButton(
                  onPressed: () => _getCurrentLocation(isInitial: false),
                  heroTag: 'btn0',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0A4DA2),
                  elevation: 4,
                  child: const Icon(Icons.my_location),
                ),
              ),
              const SizedBox(height: 10),

              // Botón para cambiar el estilo del mapa
              Tooltip(
                message: 'Change map style',
                child: FloatingActionButton(
                  onPressed: _changeMapStyle,
                  heroTag: 'btn1',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0A4DA2),
                  elevation: 4,
                  child: const Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 10),

              // Botón para activar/desactivar el modo de marcadores de oficina
              Tooltip(
                message: 'Toggle office marker mode',
                child: FloatingActionButton(
                  onPressed: _toggleMarkerMode,
                  heroTag: 'btn2',
                  backgroundColor: _markerController.markerMode
                      ? const Color(0xFF0A4DA2)
                      : Colors.white,
                  foregroundColor: _markerController.markerMode
                      ? Colors.white
                      : const Color(0xFF0A4DA2),
                  elevation: 4,
                  child: Icon(
                    _markerController.markerMode
                        ? Icons.add_location
                        : Icons.add_location_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón para activar/desactivar el modo de marcador de flecha roja
              Tooltip(
                message: 'Find nearest office',
                child: FloatingActionButton(
                  onPressed: _toggleRedArrowMode,
                  heroTag: 'btn3',
                  backgroundColor: _markerController.redArrowMode
                      ? const Color(0xFF0A4DA2)
                      : Colors.white,
                  foregroundColor: _markerController.redArrowMode
                      ? Colors.white
                      : const Color(0xFF0A4DA2),
                  elevation: 4,
                  child: Icon(
                    _markerController.redArrowMode
                        ? Icons.place
                        : Icons.place_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón para eliminar todos los marcadores
              Tooltip(
                message: 'Clear all markers',
                child: FloatingActionButton(
                  onPressed: _clearMarkers,
                  heroTag: 'btn4',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0A4DA2),
                  elevation: 4,
                  child: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ),
        ),

        // Si no hay permisos de ubicación, mostrar un mensaje para solicitarlos
        if (!_locationPermissionGranted && !_isLoadingCurrentLocation)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Permisos de Ubicación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A4DA2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Se requieren permisos de ubicación para mostrar tu posición en el mapa.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          _initializeLocation, // Corregido: llamar a _initializeLocation en lugar de _checkLocationPermission
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A4DA2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Conceder Permisos'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Panel deslizable para mostrar la oficina más cercana
        if (_showOfficePanel && _nearestOffice != null) _buildOfficePanel(),
      ],
    );
  }

  // Construye el panel deslizable con la información de la oficina más cercana
  Widget _buildOfficePanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25, // Tamaño inicial más pequeño (25% de la pantalla)
      minChildSize: 0.15, // Tamaño mínimo al que se puede reducir
      maxChildSize: 0.6, // Tamaño máximo al que se puede expandir
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 0),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              // Indicador de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Card para destacar el nombre de la oficina
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4,
                  color: const Color(0xFF0A4DA2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      _nearestOffice!.id,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido del panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado y distancia
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Open Now • Closes at ${_nearestOffice!.closeHours}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_nearestOffice!.distanceInMiles.toStringAsFixed(2)} miles',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dirección principal - Ahora muestra la dirección real
                    if (_isLoadingAddress)
                      // Mostrar un indicador de carga mientras se obtiene la dirección
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      Text(
                        // Usar la dirección real obtenida de la API o la dirección del marcador
                        _formattedAddress ?? _nearestOffice!.address,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 8),
                    // Información secundaria
                    Text(
                      _nearestOffice!.secondaryAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    // Coordenadas en una sola línea
                    const SizedBox(height: 12),
                    Text(
                      'Coordinates: ${_nearestOffice!.latitude.toStringAsFixed(6)}, ${_nearestOffice!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Botones de acción subidos más arriba
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Botón para llamar
                          ElevatedButton.icon(
                            onPressed: () {
                              // Acción para llamar a la oficina
                              launchUrl(Uri.parse('tel:+1234567890'));
                            },
                            icon: const Icon(
                              Icons.phone_in_talk_outlined,
                              color: Colors.white,
                            ),
                            label: const Text('Call Office'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A4DA2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Botón para obtener direcciones
                          OutlinedButton.icon(
                            onPressed: () {
                              // Acción para obtener direcciones
                              final url =
                                  'https://www.google.com/maps/dir/?api=1'
                                  '&origin=$_userLatitude,$_userLongitude'
                                  '&destination=${_nearestOffice!.latitude},${_nearestOffice!.longitude}';
                              launchUrl(Uri.parse(url));
                            },
                            icon: const Icon(
                              Icons.directions,
                              color: Color(0xFF0A4DA2),
                            ),
                            label: const Text(
                              'Get Directions',
                              style: TextStyle(color: Color(0xFF0A4DA2)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0A4DA2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón para cerrar el panel
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showOfficePanel = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Close'),
                      ),
                    ),

                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    _styleController.dispose();
    super.dispose();
  }
}
