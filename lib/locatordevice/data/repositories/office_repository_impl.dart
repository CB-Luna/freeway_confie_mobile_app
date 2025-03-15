import '../../domain/entities/office.dart';
import '../../domain/repositories/office_repository.dart';
import '../datasources/office_datasource.dart';

class OfficeRepositoryImpl implements OfficeRepository {
  final OfficeDataSource dataSource;

  OfficeRepositoryImpl(this.dataSource);

  @override
  Future<List<Office>> getOffices() async {
    // Simply pass through the Office objects since datasource already converts them
    return await dataSource.getOffices();
  }
}
