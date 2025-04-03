import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/platform/device_info.dart';
import '../../../data/models/office/office.dart';
import '../../../data/services/office_service.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_offices.dart';

class LocationState {
  final bool isLoading;
  final Position? currentPosition;
  final List<Office> offices; // Todas las oficinas
  final List<Office> nearbyOffices; // Oficinas dentro del radio de cobertura
  final String? errorMessage;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final bool hasLocationPermission;
  final bool hasSearchedByZipCode;
  final double searchRadiusInMiles; // Radio de búsqueda en millas
  final bool showAllOffices; // Indica si se deben mostrar todas las oficinas
  final int? selectedOfficeId; // ID de la oficina seleccionada

  LocationState({
    this.isLoading = true,
    this.currentPosition,
    this.offices = const [],
    this.nearbyOffices = const [],
    this.errorMessage,
    this.markers = const {},
    this.circles = const {},
    this.hasLocationPermission = true,
    this.hasSearchedByZipCode = false,
    this.searchRadiusInMiles = 1.0, // Por defecto, 1 milla
    this.showAllOffices = false,
    this.selectedOfficeId,
  });

  LocationState copyWith({
    bool? isLoading,
    Position? currentPosition,
    List<Office>? offices,
    List<Office>? nearbyOffices,
    String? errorMessage,
    Set<Marker>? markers,
    Set<Circle>? circles,
    bool? hasLocationPermission,
    bool? hasSearchedByZipCode,
    double? searchRadiusInMiles,
    bool? showAllOffices,
    int? selectedOfficeId,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      offices: offices ?? this.offices,
      nearbyOffices: nearbyOffices ?? this.nearbyOffices,
      errorMessage: errorMessage ?? this.errorMessage,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      hasSearchedByZipCode: hasSearchedByZipCode ?? this.hasSearchedByZipCode,
      searchRadiusInMiles: searchRadiusInMiles ?? this.searchRadiusInMiles,
      showAllOffices: showAllOffices ?? this.showAllOffices,
      selectedOfficeId: selectedOfficeId ?? this.selectedOfficeId,
    );
  }
}

class LocationController extends ChangeNotifier {
  final GetCurrentLocation getCurrentLocation;
  final GetOffices getOffices;
  final DeviceInfo deviceInfo;

  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionStreamSubscription;

  LocationState _state = LocationState();
  LocationState get state => _state;

  // Coordenadas por defecto para simuladores (San Diego) Sin covertura
  // static const double defaultLat = 32.715738;
  // static const double defaultLng = -117.161084;
  // Coordenadas por defecto para emuladores (San Diego) Con covertura
  static const double defaultLat = 32.6708864;
  static const double defaultLng = -117.1033635;

  LocationController({
    required this.getCurrentLocation,
    required this.getOffices,
    required this.deviceInfo,
  });

  Future<void> initialize() async {
    try {
      // Inicializar el estado
      _updateState(
        isLoading: true,
        errorMessage: null,
        selectedOfficeId: null,
      );

      // Verificar y solicitar permisos de ubicación
      await _checkAndRequestLocationPermission();

      // Si no tiene permisos, usar ubicación por defecto sin solicitar permisos
      if (!_state.hasLocationPermission) {
        await _useDefaultLocation();
      } else {
        await _loadCurrentLocation();
      }

      await _loadOffices();
    } catch (e) {
      _updateState(
        isLoading: false,
        errorMessage: 'Error initializing: ${e.toString()}',
      );
    }
  }

  Future<void> retry() async {
    _updateState(
      isLoading: true,
      errorMessage: null,
    );
    await initialize();
  }

  void _updateState({
    bool? isLoading,
    Position? currentPosition,
    List<Office>? offices,
    List<Office>? nearbyOffices,
    String? errorMessage,
    Set<Marker>? markers,
    Set<Circle>? circles,
    bool? hasLocationPermission,
    bool? hasSearchedByZipCode,
    double? searchRadiusInMiles,
    bool? showAllOffices,
    int? selectedOfficeId,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      currentPosition: currentPosition,
      offices: offices,
      nearbyOffices: nearbyOffices,
      errorMessage: errorMessage,
      markers: markers,
      circles: circles,
      hasLocationPermission: hasLocationPermission,
      hasSearchedByZipCode: hasSearchedByZipCode,
      searchRadiusInMiles: searchRadiusInMiles,
      showAllOffices: showAllOffices,
      selectedOfficeId: selectedOfficeId,
    );
    notifyListeners();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateState(hasLocationPermission: false);
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateState(hasLocationPermission: false);
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateState(hasLocationPermission: false);
      throw Exception('Location permissions are permanently denied');
    }

    // Si llegamos aquí, tenemos permisos
    _updateState(hasLocationPermission: true);
  }

  /// Solicita permisos de ubicación y actualiza el estado
  Future<void> requestLocationPermission() async {
    try {
      _updateState(isLoading: true, errorMessage: null);

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(
          isLoading: false,
          hasLocationPermission: false,
          errorMessage: 'Location services are disabled',
        );
        return;
      }

      final LocationPermission permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _updateState(
          isLoading: false,
          hasLocationPermission: false,
          errorMessage: 'Location permissions are denied',
        );
        return;
      }

      // Si llegamos aquí, tenemos permisos
      _updateState(hasLocationPermission: true);

      // Reiniciar la inicialización
      await initialize();
    } catch (e) {
      _updateState(
        isLoading: false,
        hasLocationPermission: false,
        errorMessage: 'Error requesting location permission: ${e.toString()}',
      );
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await getCurrentLocation.execute();
      _updateState(
        currentPosition: position,
        isLoading: false,
      );
      _startLocationTracking();
    } catch (e) {
      _updateState(
        isLoading: false,
        errorMessage: 'Could not determine your location: ${e.toString()}',
      );
    }
  }

  // Método para usar ubicación por defecto en caso de no tener permisos
  Future<void> _useDefaultLocation() async {
    debugPrint('Usando ubicación por defecto cuando no hay permisos');
    final newPosition = Position(
      latitude: defaultLat,
      longitude: defaultLng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    _updateState(
      currentPosition: newPosition,
      isLoading: false,
    );
  }

  void _startLocationTracking() {
    _positionStreamSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateState(currentPosition: position);
        _updateCurrentLocationMarker();
        _calculateDistancesToOffices();
      },
      onError: (e) {
        debugPrint('Error in position stream: $e');
      },
    );
  }

  Future<void> _loadOffices() async {
    try {
      final offices =
          await getOffices.execute(currentPosition: state.currentPosition);
      _updateState(offices: offices);

      if (state.currentPosition != null) {
        _calculateDistancesToOffices();
      }

      _updateOfficeMarkers();
    } catch (e) {
      _updateState(
        errorMessage: 'Could not load offices: ${e.toString()}',
      );
    }
  }

  void _calculateDistancesToOffices() {
    if (state.currentPosition == null || state.offices.isEmpty) return;

    final List<Office> updatedOffices = [];
    final List<Office> nearbyOffices = [];

    for (var office in state.offices) {
      updatedOffices.add(office);

      // Filtrar oficinas dentro del radio de búsqueda
      if (office.distance <= state.searchRadiusInMiles) {
        nearbyOffices.add(office);
      }
    }

    // Ordenar por distancia
    updatedOffices.sort(
      (a, b) => a.distance.compareTo(b.distance),
    );

    nearbyOffices.sort(
      (a, b) => a.distance.compareTo(b.distance),
    );

    _updateState(
      offices: updatedOffices,
      nearbyOffices: nearbyOffices,
      // Si estamos mostrando todas las oficinas, mantener ese estado
      showAllOffices: state.showAllOffices,
    );

    // Actualizar el círculo de cobertura para reflejar el radio de búsqueda
    _updateCoverageCircle();
  }

  // Método para crear un ícono personalizado para el marcador de ubicación actual
  Future<BitmapDescriptor> _createCustomMarkerIcon() async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/location/location_marker.png',
    );
  }

  // Método para actualizar el círculo de cobertura
  void _updateCoverageCircle() {
    if (state.currentPosition == null) return;

    final circles = <Circle>{};
    circles.add(
      Circle(
        circleId: const CircleId('coverage_area'),
        center: LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        // Convertir millas a metros (1 milla = 1609.34 metros)
        radius: state.searchRadiusInMiles * 1609.34,
        fillColor:
            Colors.blue.withValues(alpha: 0.15), // Color azul transparente
        strokeColor: Colors.blue.withValues(alpha: 0.5),
        strokeWidth: 1,
      ),
    );

    _updateState(circles: circles);
  }

  void _updateCurrentLocationMarker() async {
    if (state.currentPosition == null) return;

    final currentMarkers = Set<Marker>.from(state.markers);
    currentMarkers
        .removeWhere((marker) => marker.markerId.value == 'current_location');

    // Obtener el ícono personalizado
    final customIcon = await _createCustomMarkerIcon();

    currentMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Mi ubicación actual',
          snippet: state.hasLocationPermission ? null : 'Ubicación simulada',
        ),
        icon: customIcon,
        zIndex: 2,
      ),
    );

    _updateState(markers: currentMarkers);

    // Actualizar el círculo de cobertura
    _updateCoverageCircle();
  }

  void _updateOfficeMarkers() {
    if (state.offices.isEmpty) return;

    final currentMarkers = Set<Marker>.from(state.markers);
    currentMarkers.removeWhere(
      (marker) => marker.markerId.value.startsWith('office_'),
    );

    for (var i = 0; i < state.offices.length; i++) {
      final office = state.offices[i];
      final isSelected = state.selectedOfficeId == office.locationId;

      // Tamaño del marcador: más grande si está seleccionado
      final markerSize = isSelected ? 60.0 : 40.0;

      final marker = Marker(
        markerId: MarkerId('office_$i'),
        position: LatLng(office.latitude, office.longitude),
        infoWindow: InfoWindow(
          title: office.name,
          snippet: office.streetAddress,
        ),
        icon: AssetMapBitmap(
          'assets/prefix.png',
          width: markerSize.toDouble(),
          height: markerSize.toDouble(),
        ),
        zIndex:
            isSelected ? 2 : 1, // Mayor zIndex para el marcador seleccionado
        onTap: () {
          // Al hacer tap en un marcador, seleccionarlo y actualizar la vista
          goToOffice(office);
        },
      );
      // Agrego oficina seleccionada a lista de oficinas
      if (isSelected) {
        _updateState(
          selectedOfficeId: office.locationId,
          nearbyOffices: [office],
          showAllOffices: false,
        );
      }

      currentMarkers.add(marker);
    }

    _updateState(markers: currentMarkers);
  }

  void updateMapPosition() {
    if (state.currentPosition != null && mapController != null) {
      final cameraPosition = CameraPosition(
        target: LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        zoom: 14.0,
      );
      mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    updateMapPosition();
  }

  void goToOffice(Office office) {
    // Actualizar el ID de la oficina seleccionada
    _updateState(selectedOfficeId: office.locationId);

    // Actualizar los marcadores para reflejar la selección
    _updateOfficeMarkers();
  }

  // Nuevo método para navegar a la oficina y ajustar la cámara
  // Este método se usará cuando se seleccione una oficina desde la lista
  void navigateToOffice(Office office) {
    // Primero seleccionamos la oficina (actualiza marcadores)
    goToOffice(office);

    // Luego ajustamos la cámara para centrar la oficina
    if (mapController != null) {
      final cameraPosition = CameraPosition(
        target: LatLng(office.latitude, office.longitude),
        zoom: 16.0,
      );
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    }
  }

  /// Busca oficinas cercanas a un código postal
  Future<void> searchByZipCode(String zipCode) async {
    try {
      _updateState(isLoading: true, errorMessage: null, selectedOfficeId: null);

      // Crear una instancia del servicio de oficinas
      final officeService = OfficeService();

      // Obtener las oficinas cercanas al código postal
      final List<Office> nearbyOffices =
          await officeService.getNearbyOfficesByZipCode(zipCode);

      if (nearbyOffices.isEmpty) {
        _updateState(
          isLoading: false,
          hasSearchedByZipCode: false,
          errorMessage:
              'No se encontraron oficinas cercanas al código postal: $zipCode',
        );
        return;
      }

      // Usar la ubicación de la primera oficina como ubicación actual
      final firstOffice = nearbyOffices.first;
      final newPosition = Position(
        latitude: firstOffice.latitude,
        longitude: firstOffice.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      _updateState(
        currentPosition: newPosition,
        isLoading: false,
        offices: nearbyOffices,
        nearbyOffices: nearbyOffices,
        hasSearchedByZipCode: true,
      );

      // Actualizar posición del mapa y marcar oficinas
      updateMapPosition();
      _updateOfficeMarkers();
    } catch (e) {
      _updateState(
        isLoading: false,
        errorMessage:
            'Error al buscar oficinas por código postal: ${e.toString()}',
      );
    }
  }

  // Método para expandir el radio de búsqueda
  Future<void> expandSearchRadius(BuildContext context) async {
    // Incrementar el radio de búsqueda en 5 millas cada vez
    final newRadius = state.searchRadiusInMiles + 5.0;

    // Restablecer la oficina seleccionada
    _updateState(
      searchRadiusInMiles: newRadius,
      selectedOfficeId: null,
    );

    // Recalcular las oficinas cercanas con el nuevo radio
    _calculateDistancesToOffices();

    // Actualizar el zoom del mapa para mostrar el nuevo radio
    _updateCameraZoomForRadius(newRadius);

    // Mostrar un mensaje al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Search radius expanded to ${newRadius.toInt()} miles'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método para actualizar el zoom de la cámara según el radio
  void _updateCameraZoomForRadius(double radiusInMiles) {
    if (state.currentPosition != null && mapController != null) {
      // Calcular el zoom apropiado basado en el radio
      // Fórmula aproximada: zoom = 14.0 - log2(radiusInMiles)
      // Esto hace que el zoom disminuya a medida que aumenta el radio
      double zoom = 14.0 - (radiusInMiles / 2.0);
      // Asegurar que el zoom no sea demasiado pequeño
      zoom = zoom.clamp(10.0, 15.0);

      final cameraPosition = CameraPosition(
        target: LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        zoom: zoom,
      );

      mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  // Método para mostrar todas las oficinas
  void showAllOffices() {
    // Restablecer la oficina seleccionada
    _updateState(
      showAllOffices: true,
      selectedOfficeId: null,
    );

    // Actualizar los marcadores
    _updateOfficeMarkers();

    // Ajustar el zoom para mostrar todas las oficinas
    if (mapController != null && state.offices.isNotEmpty) {
      final bounds = _getBoundsForOffices(state.offices);
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    }
  }

  // Método auxiliar para obtener los límites que contienen todas las oficinas
  LatLngBounds _getBoundsForOffices(List<Office> offices) {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final office in offices) {
      if (office.latitude < minLat) minLat = office.latitude;
      if (office.latitude > maxLat) maxLat = office.latitude;
      if (office.longitude < minLng) minLng = office.longitude;
      if (office.longitude > maxLng) maxLng = office.longitude;
    }

    // Añadir un poco de margen
    minLat -= 0.1;
    maxLat += 0.1;
    minLng -= 0.1;
    maxLng += 0.1;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Método para obtener la lista de oficinas a mostrar
  List<Office> getOfficeListToDisplay() {
    // Si showAllOffices es true o no hay oficinas cercanas, mostrar todas las oficinas
    if (state.showAllOffices || state.nearbyOffices.isEmpty) {
      return state.offices;
    }
    // De lo contrario, mostrar solo las oficinas cercanas
    return state.nearbyOffices;
  }

  // Método para verificar si hay oficinas cercanas
  bool hasNearbyOffices() {
    return state.nearbyOffices.isNotEmpty;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
