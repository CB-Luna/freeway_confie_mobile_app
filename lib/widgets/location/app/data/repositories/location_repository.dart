import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';

import '../../domain/models/office_location.dart';
import '../../ui/utils/distance_calculator.dart';
import '../models/location_model.dart';
import '../office_data.dart';

class LocationRepository {
  /// Obtiene la ubicación actual del dispositivo
  Future<LocationModel> getCurrentLocation() async {
    // Verificar si los servicios de ubicación están habilitados
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados');
    }

    // Verificar permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente');
    }

    // Obtener la ubicación actual
    final Position position = await Geolocator.getCurrentPosition();

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Obtiene las ubicaciones guardadas
  Future<List<LocationModel>> getSavedLocations() async {
    // TODO(dev): Implementar almacenamiento local usando SharedPreferences o Hive
    return [];
  }

  /// Guarda una ubicación
  Future<void> saveLocation(LocationModel location) async {
    // TODO(dev): Implementar almacenamiento local usando SharedPreferences o Hive
  }

  /// Obtiene las oficinas de Freeway Insurance con distancias calculadas
  Future<List<OfficeLocation>> getOfficesWithDistances() async {
    try {
      // Obtener las oficinas
      final List<OfficeLocation> offices = OfficeData.getOffices();
      
      // Convertir oficinas a formato de mapa para el cálculo de distancias
      final List<Map<String, dynamic>> officesMaps = offices.map((office) => {
        'id': office.id,
        'latitude': office.latitude,
        'longitude': office.longitude,
        'address': office.address,
        'secondaryAddress': office.secondaryAddress,
        'isOpen': office.isOpen,
        'closeHours': office.closeHours,
        'reference': office.reference,
        'rating': office.rating,
      },).toList();
      
      // Calcular distancias para todas las oficinas desde la ubicación actual
      final List<Map<String, dynamic>> officesWithDistances = 
          await DistanceCalculator.calculateDistancesFromCurrentLocation(officesMaps);
      
      // Convertir de nuevo a objetos OfficeLocation
      final List<OfficeLocation> result = officesWithDistances.map((officeMap) => OfficeLocation(
        id: officeMap['id'] as String,
        latitude: officeMap['latitude'] as double,
        longitude: officeMap['longitude'] as double,
        address: officeMap['address'] as String,
        secondaryAddress: officeMap['secondaryAddress'] as String,
        isOpen: officeMap['isOpen'] as bool,
        closeHours: officeMap['closeHours'] as String,
        distanceInMiles: officeMap['distanceInMiles'] as double,
        reference: officeMap['reference'] as String,
        rating: officeMap['rating'] as double,
      ),).toList();
      
      return result;
    } catch (e) {
      developer.log('Error al obtener oficinas con distancias: $e', name: 'LocationRepository');
      // En caso de error, devolver las oficinas sin distancias calculadas
      return OfficeData.getOffices();
    }
  }
  
  /// Obtiene la oficina más cercana a la ubicación actual del dispositivo
  Future<OfficeLocation?> getNearestOffice() async {
    try {
      // Obtener todas las oficinas con distancias calculadas
      final List<OfficeLocation> offices = await getOfficesWithDistances();
      
      // Verificar si hay oficinas disponibles
      if (offices.isEmpty) {
        return null;
      }
      
      // La primera oficina es la más cercana ya que están ordenadas por distancia
      return offices.first;
    } catch (e) {
      developer.log('Error al obtener la oficina más cercana: $e', name: 'LocationRepository');
      return null;
    }
  }
}
