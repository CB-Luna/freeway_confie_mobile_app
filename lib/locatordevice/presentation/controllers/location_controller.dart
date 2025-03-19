import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/platform/device_info.dart';
import '../../domain/entities/office.dart';
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
  final bool isEmulatorOrSimulator;
  final double searchRadiusInMiles; // Radio de búsqueda en millas
  final bool showAllOffices; // Indica si se deben mostrar todas las oficinas

  LocationState({
    this.isLoading = true,
    this.currentPosition,
    this.offices = const [],
    this.nearbyOffices = const [],
    this.errorMessage,
    this.markers = const {},
    this.circles = const {},
    this.isEmulatorOrSimulator = false,
    this.searchRadiusInMiles = 1.0, // Por defecto, 1 milla
    this.showAllOffices = false,
  });

  LocationState copyWith({
    bool? isLoading,
    Position? currentPosition,
    List<Office>? offices,
    List<Office>? nearbyOffices,
    String? errorMessage,
    Set<Marker>? markers,
    Set<Circle>? circles,
    bool? isEmulatorOrSimulator,
    double? searchRadiusInMiles,
    bool? showAllOffices,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      offices: offices ?? this.offices,
      nearbyOffices: nearbyOffices ?? this.nearbyOffices,
      errorMessage: errorMessage ?? this.errorMessage,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
      isEmulatorOrSimulator:
          isEmulatorOrSimulator ?? this.isEmulatorOrSimulator,
      searchRadiusInMiles: searchRadiusInMiles ?? this.searchRadiusInMiles,
      showAllOffices: showAllOffices ?? this.showAllOffices,
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

  // Coordenadas por defecto para simuladores (San Diego)
  static const double defaultLat = 32.715738;
  static const double defaultLng = -117.161084;

  LocationController({
    required this.getCurrentLocation,
    required this.getOffices,
    required this.deviceInfo,
  });

  Future<void> initialize() async {
    try {
      await _detectIfEmulator();

      // Si estamos en un emulador, usar ubicación por defecto sin solicitar permisos
      if (_state.isEmulatorOrSimulator) {
        await _useDefaultLocationForEmulator();
      } else {
        await _checkAndRequestLocationPermission();
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
    bool? isEmulatorOrSimulator,
    double? searchRadiusInMiles,
    bool? showAllOffices,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      currentPosition: currentPosition,
      offices: offices,
      nearbyOffices: nearbyOffices,
      errorMessage: errorMessage,
      markers: markers,
      circles: circles,
      isEmulatorOrSimulator: isEmulatorOrSimulator,
      searchRadiusInMiles: searchRadiusInMiles,
      showAllOffices: showAllOffices,
    );
    notifyListeners();
  }

  Future<void> _detectIfEmulator() async {
    final isEmulator = await deviceInfo.isEmulatorOrSimulator();
    _updateState(isEmulatorOrSimulator: isEmulator);

    if (isEmulator) {
      debugPrint('Detectado emulador/simulador - usando ubicación simulada');
    }
  }

  Future<void> _checkAndRequestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
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

  // Método para usar ubicación por defecto en emuladores
  Future<void> _useDefaultLocationForEmulator() async {
    debugPrint('Usando ubicación por defecto para emulador/simulador');
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

    // Agregamos el marcador para la ubicación simulada
    _updateCurrentLocationMarker();
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
      final offices = await getOffices.execute();
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
      final double distanceInMeters = Geolocator.distanceBetween(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
        office.latitude,
        office.longitude,
      );

      final double distanceInMiles = distanceInMeters * 0.000621371;

      final updatedOffice = Office.fromMap({
        ...office.toMap(),
        'distanceInMiles': distanceInMiles,
      });
      
      updatedOffices.add(updatedOffice);
      
      // Filtrar oficinas dentro del radio de búsqueda
      if (distanceInMiles <= state.searchRadiusInMiles) {
        nearbyOffices.add(updatedOffice);
      }
    }

    // Ordenar por distancia
    updatedOffices.sort(
      (a, b) => a.distanceInMiles.compareTo(b.distanceInMiles),
    );
    
    nearbyOffices.sort(
      (a, b) => a.distanceInMiles.compareTo(b.distanceInMiles),
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
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
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
        fillColor: Colors.blue.withOpacity(0.15), // Color azul transparente
        strokeColor: Colors.blue.withOpacity(0.5),
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
          snippet: state.isEmulatorOrSimulator ? 'Ubicación simulada' : null,
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
      final marker = Marker(
        markerId: MarkerId('office_$i'),
        position: LatLng(office.latitude, office.longitude),
        infoWindow: InfoWindow(
          title: office.name,
          snippet: office.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        zIndex: 1,
      );
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

  void setCustomLocation(double latitude, double longitude) {
    final newPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    _updateState(currentPosition: newPosition);
    _updateCurrentLocationMarker();
    updateMapPosition();
    _calculateDistancesToOffices();
  }

  void setEmulatorMode(bool value) {
    _updateState(isEmulatorOrSimulator: value);
  }

  // Método para expandir el radio de búsqueda
  void expandSearchRadius() {
    // Incrementar el radio de búsqueda en 1 milla
    final newRadius = state.searchRadiusInMiles + 1.0;
    _updateState(searchRadiusInMiles: newRadius, showAllOffices: false);
    
    // Recalcular las oficinas cercanas con el nuevo radio
    _calculateDistancesToOffices();
  }

  // Método para mostrar todas las oficinas
  void showAllOffices() {
    _updateState(showAllOffices: true);
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
