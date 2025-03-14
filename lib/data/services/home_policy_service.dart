import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/home_policy/home_policy_request.dart';
import '../models/home_policy/vehicle.dart';

class HomePolicyService {
  static const String baseUrl = 'https://u-n8n.virtalus.cbluna-dev.com';
  static const String homePoliciesEndpoint = '/webhook/confie_home_policies';

  Future<List<Vehicle>> getHomePolicies(int customerId) async {
    try {
      final request = HomePolicyRequest(customerId: customerId);

      debugPrint('Fetching policies for customer_id: $customerId');

      final response = await http.post(
        Uri.parse('$baseUrl$homePoliciesEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        debugPrint('Response received: ${response.body}');

        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          debugPrint('API returned empty list for customer_id: $customerId');
          return [];
        }

        final List<Vehicle> vehicles = [];

        for (var item in jsonResponse) {
          try {
            // Verificar y corregir campos nulos que deberían ser números
            if (item is Map<String, dynamic>) {
              // Asegurar que los campos requeridos no sean nulos
              item['vehicle_id'] ??= 0;
              item['provider_id'] ??= 1;
              item['policy_type_id'] ??= 2;
              item['customer_id'] ??= customerId;

              // Asegurar que los campos de texto requeridos no sean nulos
              item['plate'] ??= 'UNKNOWN';
              item['brand'] ??= 'Unknown';
              item['model'] ??= 'Unknown';
              item['provider_image'] ??= 'assets/home/icons/Bluefire.svg';
              item['policy_type'] ??= 'My Auto Policy';
              item['next_payment_date'] ??= '2025-01-01';

              vehicles.add(Vehicle.fromJson(item));
              debugPrint(
                'Successfully added vehicle: ${item['plate']} with policy_type_id: ${item['policy_type_id']}',
              );
            }
          } catch (e) {
            debugPrint('Error parsing vehicle: $e');
            debugPrint('Problematic JSON: $item');
          }
        }

        debugPrint('Successfully parsed ${vehicles.length} vehicles');
        return vehicles;
      } else {
        throw Exception('Failed to load home policies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getHomePolicies: $e');
      throw Exception('Failed to load policies: $e');
    }
  }
}
