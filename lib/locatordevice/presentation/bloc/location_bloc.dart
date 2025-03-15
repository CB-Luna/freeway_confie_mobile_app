import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/office.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_offices.dart';

// Simple implementation to avoid adding a state management package dependency
class LocationBloc {
  final GetCurrentLocation _getCurrentLocation;
  final GetOffices _getOffices;
  Position? _currentPosition;

  // Stream controllers for location states
  final _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;

  final _officesController = StreamController<List<Office>>.broadcast();
  Stream<List<Office>> get officesStream => _officesController.stream;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  LocationBloc(this._getCurrentLocation, this._getOffices);

  Future<void> loadCurrentLocation() async {
    try {
      debugPrint('LocationBloc: Loading current location');
      _currentPosition = await _getCurrentLocation.execute();
      _locationController.add(_currentPosition!);

      // Recargar las oficinas con la nueva ubicación
      await loadNearbyOffices();
    } catch (e) {
      debugPrint('LocationBloc: Error loading location: $e');
      _errorController.add(e.toString());
    }
  }

  Future<void> loadNearbyOffices() async {
    try {
      debugPrint('LocationBloc: Loading nearby offices');
      final offices =
          await _getOffices.execute(currentPosition: _currentPosition);
      _officesController.add(offices);
    } catch (e) {
      debugPrint('LocationBloc: Error loading offices: $e');
      _errorController.add(e.toString());
    }
  }

  void dispose() {
    _locationController.close();
    _officesController.close();
    _errorController.close();
  }
}
