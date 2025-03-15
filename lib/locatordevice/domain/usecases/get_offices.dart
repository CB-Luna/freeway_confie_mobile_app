import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../entities/office.dart';
import '../repositories/office_repository.dart';

class GetOffices {
  final OfficeRepository repository;

  GetOffices(this.repository);

  Future<List<Office>> execute({Position? currentPosition}) async {
    try {
      debugPrint('GetOffices: Executing use case');
      final offices = await repository.getOffices();

      if (currentPosition != null) {
        // Calcular distancias y ordenar si tenemos una posición actual
        final officesWithDistances = offices.map((office) {
          final distanceInMeters = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            office.latitude,
            office.longitude,
          );

          return Office.fromMap({
            ...office.toMap(),
            'distanceInMiles':
                distanceInMeters * 0.000621371, // Convertir a millas
          });
        }).toList();

        // Ordenar por distancia
        officesWithDistances.sort(
          (a, b) => a.distanceInMiles.compareTo(b.distanceInMiles),
        );

        return officesWithDistances;
      }

      return offices;
    } catch (e) {
      debugPrint('GetOffices: Error executing use case: $e');
      rethrow;
    }
  }
}
