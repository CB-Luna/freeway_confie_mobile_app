import 'package:flutter/foundation.dart';

import '../entities/office.dart';
import '../repositories/office_repository.dart';

class GetOffices {
  final OfficeRepository repository;

  GetOffices(this.repository);

  Future<List<Office>> execute() async {
    try {
      debugPrint('GetOffices: Executing use case');
      final offices = await repository.getOffices();
      debugPrint('GetOffices: Found ${offices.length} offices');
      return offices;
    } catch (e) {
      debugPrint('GetOffices: Error executing use case: $e');
      rethrow;
    }
  }
}
