import 'package:flutter/material.dart';
import '../models/office_location.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  error,
  noLocationsFound,
  geoDetectionNotAvailable
}

class LocationService extends ChangeNotifier {
  LocationStatus _status = LocationStatus.initial;
  List<OfficeLocation> _nearbyOffices = [];
  String _errorMessage = '';
  double _searchRadius = 10.0; // en millas

  LocationStatus get status => _status;
  List<OfficeLocation> get nearbyOffices => _nearbyOffices;
  String get errorMessage => _errorMessage;
  double get searchRadius => _searchRadius;

  Future<void> getCurrentLocation() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      // Simulamos obtener la ubicación actual
      await Future.delayed(const Duration(seconds: 1));

      await findNearbyOffices();
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = 'Error al obtener la ubicación: $e';
      notifyListeners();
    }
  }

  Future<void> findNearbyOffices() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      // Simulamos una llamada a API
      await Future.delayed(const Duration(seconds: 1));

      // Datos de ejemplo
      _nearbyOffices = _getMockOffices();

      if (_nearbyOffices.isEmpty) {
        _status = LocationStatus.noLocationsFound;
      } else {
        _status = LocationStatus.success;
      }
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = 'Error al buscar oficinas cercanas: $e';
    }

    notifyListeners();
  }

  void expandSearchRadius() {
    _searchRadius += 10.0; // Incrementar en 10 millas
    findNearbyOffices();
  }

  Future<void> searchByZipCode(String zipCode) async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      // Simulamos una llamada a API
      await Future.delayed(const Duration(seconds: 1));

      // Datos de ejemplo
      _nearbyOffices = _getMockOffices();

      if (_nearbyOffices.isEmpty) {
        _status = LocationStatus.noLocationsFound;
      } else {
        _status = LocationStatus.success;
      }
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = 'Error al buscar por código postal: $e';
    }

    notifyListeners();
  }

  // Datos de ejemplo
  List<OfficeLocation> _getMockOffices() {
    return [
      OfficeLocation(
        id: '1',
        name: 'Freeway Insurance',
        address: '7400 Main St. Los Angeles CA 90020',
        secondaryAddress: '401 South Vermont #15',
        reference: '5th st / Vermont',
        latitude: 34.0522,
        longitude: -118.2437,
        openHours: '9am',
        closeHours: '7pm',
        rating: 4.5,
        distanceInMiles: 0.77,
        isOpen: true,
      ),
      // Más oficinas de ejemplo...
    ];
  }
}
