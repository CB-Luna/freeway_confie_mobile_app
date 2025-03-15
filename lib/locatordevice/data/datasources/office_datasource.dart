import 'package:flutter/foundation.dart';

import '../../domain/entities/office.dart';

abstract class OfficeDataSource {
  Future<List<Office>> getOffices();
}

class OfficeDataSourceImpl implements OfficeDataSource {
  @override
  Future<List<Office>> getOffices() async {
    debugPrint('OfficeDataSourceImpl: Getting offices');
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final List<Map<String, dynamic>> rawData = [
      // Oficina 1: Chula Vista
      {
        'id': '1',
        'name': 'Seguro de auto en Chula Vista',
        'latitude': 32.6024602,
        'longitude': -117.0804273,
        'address': '624 Palomar St Ste 701, CA 91911',
        'phone': '619-399-2387',
      },
      // Oficina 2: National City
      {
        'id': '2',
        'name': 'Seguro de auto en National City',
        'latitude': 32.6773538,
        'longitude': -117.0962897,
        'address': '1401 E Plaza Blvd #E, National City, CA 91950',
        'phone': '619-618-2400',
      },
    ];

    return rawData.map((data) => Office.fromMap(data)).toList();
  }
}
