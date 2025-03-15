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
  final List<Office> offices;
  final String? errorMessage;
  final Set<Marker> markers;
  final bool isEmulatorOrSimulator;

  LocationState({
    this.isLoading = true,
    this.currentPosition,
    this.offices = const [],
    this.errorMessage,
    this.markers = const {},
    this.isEmulatorOrSimulator = false,
  });

  LocationState copyWith({
    bool? isLoading,
    Position? currentPosition,
    List<Office>? offices,
    String? errorMessage,
    Set<Marker>? markers,
    bool? isEmulatorOrSimulator,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      offices: offices ?? this.offices,
      errorMessage: errorMessage ?? this.errorMessage,
      markers: markers ?? this.markers,
      isEmulatorOrSimulator:
          isEmulatorOrSimulator ?? this.isEmulatorOrSimulator,
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
    String? errorMessage,
    Set<Marker>? markers,
    bool? isEmulatorOrSimulator,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      currentPosition: currentPosition,
      offices: offices,
      errorMessage: errorMessage,
      markers: markers,
      isEmulatorOrSimulator: isEmulatorOrSimulator,
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

    for (var office in state.offices) {
      final double distanceInMeters = Geolocator.distanceBetween(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
        office.latitude,
        office.longitude,
      );

      final double distanceInMiles = distanceInMeters * 0.000621371;

      updatedOffices.add(
        Office.fromMap({
          ...office.toMap(),
          'distanceInMiles': distanceInMiles,
        }),
      );
    }

    updatedOffices.sort(
      (a, b) => a.distanceInMiles.compareTo(b.distanceInMiles),
    );

    _updateState(offices: updatedOffices);
  }

  void _updateCurrentLocationMarker() {
    if (state.currentPosition == null) return;

    final currentMarkers = Set<Marker>.from(state.markers);
    currentMarkers
        .removeWhere((marker) => marker.markerId.value == 'current_location');

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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndex: 2,
      ),
    );

    _updateState(markers: currentMarkers);
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

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
