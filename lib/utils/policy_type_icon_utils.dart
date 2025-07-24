import 'package:flutter/material.dart';

/// Utilidad para manejar los iconos de tipos de pólizas
class PolicyTypeIconUtils {
  /// Lista de nombres de iconos disponibles en assets/home/idcardicons/policy_type
  static const List<String> availableIcons = [
    'atv',
    'auto',
    'auto_club',
    'auto_loan',
    'business_insurance',
    'classic_car',
    'commercial_auto',
    'dent_repair',
    'dental_insurance',
    'health_insurance',
    'homeowners',
    'hospital_indemnity',
    'identity_theft_protection',
    'landlord',
    'life_insurance',
    'mexican_car_insurance',
    'mobile_home_insurance',
    'motorcycle',
    'motorhome',
    'one_stop_dui',
    'pet_health',
    'pet_insurance',
    'renters',
    'rideshare_insurance',
    'rv_motorhome',
    'snowmobile',
    'sr_22',
    'tax_preparation',
    'telemedicine',
    'tire_hazard_protection',
    'travel_club_add',
    'vrr_online_california',
    'windshield_repair',
  ];

  /// Icono predeterminado para usar cuando no se encuentra un icono específico
  static const String defaultIcon = 'default';

  /// Verifica si existe un icono para el tipo de póliza dado
  static bool hasIconForPolicyType(String policyType) {
    final normalizedType = policyType.toLowerCase().replaceAll(' ', '_');
    return availableIcons.contains(normalizedType);
  }

  /// Obtiene la ruta del asset para el icono del tipo de póliza
  /// Si no existe un icono específico, devuelve la ruta al icono predeterminado
  static String getPolicyTypeIconPath(String policyType) {
    final normalizedType = policyType.toLowerCase().replaceAll(' ', '_');
    if (availableIcons.contains(normalizedType)) {
      return 'assets/home/idcardicons/policy_type/$normalizedType.png';
    }
    return 'assets/home/idcardicons/policy_type/$defaultIcon.png';
  }

  /// Obtiene el widget de imagen para el icono del tipo de póliza
  /// Si no existe un icono específico, devuelve el icono predeterminado
  static Widget getPolicyTypeIcon(
    String policyType, {
    double? width,
    double? height,
  }) {
    return Image.asset(
      getPolicyTypeIconPath(policyType),
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        // Si hay un error al cargar la imagen, mostrar el icono predeterminado
        return Image.asset(
          'assets/home/idcardicons/policy_type/$defaultIcon.png',
          width: width,
          height: height,
        );
      },
    );
  }
}
