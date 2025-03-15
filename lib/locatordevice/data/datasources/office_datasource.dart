import 'package:flutter/foundation.dart';

abstract class OfficeDataSource {
  Future<List<Map<String, dynamic>>> getOffices();
}

class OfficeDataSourceImpl implements OfficeDataSource {
  @override
  Future<List<Map<String, dynamic>>> getOffices() async {
    // Mock data for now - would be replaced with actual API calls
    debugPrint('OfficeDataSourceImpl: Getting offices');

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      // Oficina 1: Chula Vista - Coordenadas corregidas
      {
        'id': 1,
        'name': 'Seguro de auto en Chula Vista',
        'latitude': 32.611196, // Coordenadas corregidas para Chula Vista
        'longitude': -117.059724,
        'address': '1295 Broadway #201, Chula Vista, CA 91911',
        'secondaryAddress': 'California, Chula Vista, 91911, USA',
        'isOpen': true,
        'closeHours': '8pm',
        'distanceInMiles': 0, // Se calculará dinámicamente
        'reference': 'Cerca de Plaza Bonita Mall',
        'rating': 4.7,
        'phone': '619-399-2387',
      },

      // Oficina 2: National City - Coordenadas corregidas
      {
        'id': 2,
        'name': 'Seguro de auto en National City',
        'latitude': 32.678076, // Coordenadas corregidas para National City
        'longitude': -117.099606,
        'address': '1401 E Plaza Blvd #E, National City, CA 91950',
        'secondaryAddress': 'California, National City, 91950, USA',
        'isOpen': true,
        'closeHours': '8pm',
        'distanceInMiles': 0, // Se calculará dinámicamente
        'reference': 'Plaza East Shopping Center',
        'rating': 4.7,
        'phone': '619-618-2400',
      },
    ];
  }
}
