import 'package:flutter/material.dart';
import '../data/models/home_policy/vehicle.dart';
import '../data/services/home_policy_service.dart';

class HomePolicyProvider with ChangeNotifier {
  final HomePolicyService _homePolicyService = HomePolicyService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Obtener el vehículo con provider_id = 1 (BlueFire Insurance)
  Vehicle? get blueFireVehicle => _vehicles.isNotEmpty
      ? _vehicles.firstWhere((vehicle) => vehicle.providerId == 1,
          orElse: () => _vehicles.first,)
      : null;

  // Obtener el vehículo con provider_id = 2 (Freeway Insurance)
  Vehicle? get freewayVehicle => _vehicles.isNotEmpty
      ? _vehicles.firstWhere((vehicle) => vehicle.providerId == 2,
          orElse: () => _vehicles.first,)
      : null;

  // Obtener vehículos por policy_type_id
  List<Vehicle> getVehiclesByPolicyTypeId(int policyTypeId) {
    return _vehicles
        .where((vehicle) => vehicle.policyTypeId == policyTypeId)
        .toList();
  }

  // Verificar si hay vehículos de un tipo específico
  bool hasPolicyTypeId(int policyTypeId) {
    return _vehicles.any((vehicle) => vehicle.policyTypeId == policyTypeId);
  }

  // Método para simular un vehículo inactivo para pruebas
  Vehicle? get inactiveVehicle {
    if (_vehicles.isEmpty) {
      final vehicle = Vehicle(
        vehicleId: 999,
        plate: 'CAAAPO000380829',
        brand: 'Toyota',
        model: 'Corolla',
        vehicleTypeId: 1,
        vehicleType: 'Car',
        providerId: 1,
        providerImage: 'assets/home/icons/Bluefire.svg',
        policyTypeId: 3, // Tipo de póliza inactiva
        policyType: 'My Auto Policy',
        transactionType: 'Monthly Plan',
        memberSince: 'Jan 2025',
        nextPaymentDate: '2025-05-15',
        customerId: 1,
      );

      return vehicle;
    }

    // Si hay vehículos, buscar uno con policy_type_id = 3 (inactivo)
    final inactiveVehicles =
        _vehicles.where((v) => v.policyTypeId == 3).toList();
    if (inactiveVehicles.isNotEmpty) {
      return inactiveVehicles.first;
    }

    // Si no hay vehículos inactivos, crear uno basado en el primero
    final vehicle = _vehicles.first;
    // No podemos modificar directamente el objeto Vehicle porque es inmutable,
    // así que creamos uno nuevo con policyTypeId = 3
    final inactiveVehicle = Vehicle(
      vehicleId: vehicle.vehicleId,
      plate: vehicle.plate,
      brand: vehicle.brand,
      model: vehicle.model,
      vehicleTypeId: vehicle.vehicleTypeId,
      vehicleType: vehicle.vehicleType,
      providerId: vehicle.providerId,
      providerImage: vehicle.providerImage,
      policyTypeId: 3, // Tipo de póliza inactiva
      policyType: vehicle.policyType,
      transactionType: vehicle.transactionType,
      memberSince: vehicle.memberSince,
      serviceId: vehicle.serviceId,
      serviceName: vehicle.serviceName,
      nextPaymentDate: vehicle.nextPaymentDate,
      customerId: vehicle.customerId,
    );

    return inactiveVehicle;
  }

  Future<void> fetchHomePolicies(int customerId) async {
    // Si ya está cargando, no hacer nada
    if (_isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      // Notificar antes de la llamada a la API
      notifyListeners();

      // Simular un pequeño retraso para mostrar el indicador de carga
      await Future.delayed(const Duration(milliseconds: 500));

      _vehicles = await _homePolicyService.getHomePolicies(customerId);

      _isLoading = false;
      // Notificar después de recibir la respuesta
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load policies: ${e.toString()}';
      // Notificar en caso de error
      notifyListeners();
    }
  }
}
