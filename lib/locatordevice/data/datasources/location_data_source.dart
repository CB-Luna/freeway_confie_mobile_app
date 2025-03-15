import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<Position> getCurrentPosition();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position> getCurrentPosition() async {
    debugPrint('LocationDataSourceImpl: Getting current position');

    // Check if location services are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('LocationDataSourceImpl: Location services are disabled');
      throw Exception('Location services are disabled');
    }

    // Check for permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('LocationDataSourceImpl: Location permissions are denied');
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
        'LocationDataSourceImpl: Location permissions are permanently denied',
      );
      throw Exception('Location permissions are permanently denied');
    }

    // Get position with higher accuracy
    try {
      debugPrint(
        'LocationDataSourceImpl: Getting position from Geolocator with high accuracy',
      );
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint(
        'LocationDataSourceImpl: Position retrieved: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      debugPrint('LocationDataSourceImpl: Error getting position: $e');
      rethrow;
    }
  }
}
