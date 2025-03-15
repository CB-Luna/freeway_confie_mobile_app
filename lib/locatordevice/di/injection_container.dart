import 'package:flutter/foundation.dart';

import '../../../core/platform/device_info.dart';
import '../data/datasources/location_data_source.dart';
import '../data/datasources/office_datasource.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/office_repository_impl.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/office_repository.dart';
import '../domain/usecases/get_current_location.dart';
import '../domain/usecases/get_offices.dart';
import '../presentation/bloc/location_bloc.dart';

/// Simple service locator without external dependencies
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, Object> _dependencies = {};

  /// Register a dependency
  void registerSingleton<T extends Object>(T instance) {
    _dependencies[T] = instance;
  }

  /// Get a registered dependency
  T get<T extends Object>() {
    final instance = _dependencies[T];
    if (instance == null) {
      throw Exception('Type $T not registered in service locator');
    }
    return instance as T;
  }

  /// Check if a dependency is registered
  bool isRegistered<T extends Object>() {
    return _dependencies.containsKey(T);
  }
}

// Use our custom service locator
final sl = ServiceLocator();

/// Initializes dependencies for the LocatorDevice module
Future<void> init() async {
  debugPrint('Initializing Locator Device dependencies...');

  try {
    // Platform/External
    sl.registerSingleton<DeviceInfo>(DeviceInfo());

    // Data sources
    final locationDataSource = LocationDataSourceImpl();
    sl.registerSingleton<LocationDataSource>(locationDataSource);

    final officeDataSource = OfficeDataSourceImpl();
    sl.registerSingleton<OfficeDataSource>(officeDataSource);

    // Repositories
    final locationRepository = LocationRepositoryImpl(locationDataSource);
    sl.registerSingleton<LocationRepository>(locationRepository);

    final officeRepository = OfficeRepositoryImpl(officeDataSource);
    sl.registerSingleton<OfficeRepository>(officeRepository);

    // Use cases
    final getCurrentLocation = GetCurrentLocation(locationRepository);
    sl.registerSingleton<GetCurrentLocation>(getCurrentLocation);

    final getOffices = GetOffices(officeRepository);
    sl.registerSingleton<GetOffices>(getOffices);

    // BLoC
    final locationBloc = LocationBloc(getCurrentLocation, getOffices);
    sl.registerSingleton<LocationBloc>(locationBloc);

    debugPrint('All dependencies registered successfully');
  } catch (e) {
    debugPrint('Error registering dependencies: $e');
    rethrow; // Re-throw to be caught by the caller
  }
}
