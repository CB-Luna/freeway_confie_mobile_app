import 'package:flutter/material.dart';

import '../data/models/auth/policy_model.dart';

class HomePolicyProvider with ChangeNotifier {
  List<PolicyModel> _policies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PolicyModel> get policies => _policies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Obtener la póliza con carrier BlueFire Insurance
  PolicyModel? get blueFirePolicy => _policies.isNotEmpty
      ? _policies.firstWhere(
          (policy) => policy.carrierName.toLowerCase().contains('bluefire'),
          orElse: () => _policies.first,
        )
      : null;

  // Obtener la póliza con carrier Freeway Insurance
  PolicyModel? get freewayPolicy => _policies.isNotEmpty
      ? _policies.firstWhere(
          (policy) => policy.carrierName.toLowerCase().contains('freeway'),
          orElse: () => _policies.first,
        )
      : null;

  // Obtener pólizas por tipo (Auto, Roadside Assistance, etc.)
  List<PolicyModel> getPoliciesByType(String policyType) {
    // 1: Roadside Assistance, 2: Auto, 3: Inactive (simulado)
    switch (policyType) {
      case 'Roadside Assistance': // Roadside Assistance
        return _policies
            .where(
              (policy) =>
                  policy.lineOfBusiness.toLowerCase().contains('roadside') ||
                  policy.lineOfBusiness.toLowerCase().contains('assistance'),
            )
            .toList();
      case 'Auto': // Auto
        return _policies
            .where(
              (policy) => policy.lineOfBusiness.toLowerCase().contains('auto'),
            )
            .toList();
      case 'Inactive': // Inactive - Simulamos pólizas inactivas basadas en la fecha de expiración
        final now = DateTime.now();
        return _policies.where((policy) {
          try {
            final expirationDate = DateTime.parse(policy.expirationDate);
            return expirationDate
                .isBefore(now); // Consideramos inactiva si ya expiró
          } catch (e) {
            return false;
          }
        }).toList();
      default:
        return [];
    }
  }

  // Verificar si hay pólizas de un tipo específico
  bool hasPolicyType(String policyType) {
    return getPoliciesByType(policyType).isNotEmpty;
  }

  // Método para simular una póliza inactiva para pruebas
  PolicyModel? get inactivePolicy {
    // Primero buscar si ya hay una póliza inactiva
    final inactivePolicies = getPoliciesByType('Inactive');
    if (inactivePolicies.isNotEmpty) {
      return inactivePolicies.first;
    }

    // Si no hay pólizas o no hay inactivas, crear una simulada
    if (_policies.isEmpty) {
      return PolicyModel(
        policyId: '999',
        policyNumber: 'CAAAPO000380829',
        carrierName: 'BlueFire Insurance',
        lineOfBusiness: 'Auto',
        effectiveDate: '2023-01-01',
        expirationDate: '2022-05-15', // Fecha expirada para simular inactividad
        createdDate: '2022-01-01',
        programName: 'Standard Auto',
        organizationName: 'Freeway Insurance',
        organizationCode: 'FWI',
      );
    }

    // Si hay pólizas pero ninguna inactiva, crear una basada en la primera
    final policy = _policies.first;
    return PolicyModel(
      policyId: policy.policyId,
      policyNumber: policy.policyNumber,
      carrierName: policy.carrierName,
      lineOfBusiness: policy.lineOfBusiness,
      effectiveDate: policy.effectiveDate,
      // Modificamos la fecha de expiración para que sea una fecha pasada
      expirationDate: policy.expirationDate,
      createdDate: policy.createdDate,
      programName: policy.programName,
      organizationName: policy.organizationName,
      organizationCode: policy.organizationCode,
      nextPaymentDate: policy.nextPaymentDate,
    );
  }

  // Método para obtener pólizas desde el AuthProvider
  Future<void> fetchHomePolicies(List<PolicyModel> policies) async {
    // Si ya está cargando, no hacer nada
    if (_isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      // Notificar antes de obtener las pólizas
      notifyListeners();

      // Simular un pequeño retraso para mostrar el indicador de carga
      await Future.delayed(const Duration(milliseconds: 500));

      // Obtener las pólizas desde el AuthProvider
      if (policies.isNotEmpty) {
        _policies = policies;
      } else {
        // Si no hay pólizas, establecer una lista vacía
        _policies = [];
        _errorMessage = 'No policies found for customer';
      }

      _isLoading = false;
      // Notificar después de obtener las pólizas
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load policies: ${e.toString()}';
      // Notificar en caso de error
      notifyListeners();
    }
  }
}
