import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../pages/map_page.dart';

class LocationHomePage extends StatefulWidget {
  const LocationHomePage({super.key});

  @override
  State<LocationHomePage> createState() => _LocationHomePageState();
}

class _LocationHomePageState extends State<LocationHomePage> {
  // Método para calcular distancias desde la ubicación actual
  Future<List<Map<String, dynamic>>> _calculateDistances(
    List<Map<String, dynamic>> offices,
  ) async {
    try {
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

      final List<Map<String, dynamic>> officesWithDistances = [];

      // Calcular distancias para cada oficina
      for (final office in offices) {
        final double officeLat = office['latitude'] as double;
        final double officeLon = office['longitude'] as double;

        // Calcular distancia usando Geolocator
        final double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          officeLat,
          officeLon,
        );

        // Convertir metros a millas (1 metro = 0.000621371 millas)
        final double distanceInMiles = distanceInMeters * 0.000621371;

        // Agregar la oficina con su distancia calculada
        officesWithDistances.add({
          ...office,
          'distanceInMiles': distanceInMiles,
        });
      }

      // Ordenar por distancia (la más cercana primero)
      officesWithDistances.sort(
        (a, b) => (a['distanceInMiles'] as double)
            .compareTo(b['distanceInMiles'] as double),
      );

      return officesWithDistances;
    } catch (e) {
      developer.log(
        'Error al calcular distancias: $e',
        name: 'LocationHomePage',
      );
      // Devolver la lista original sin distancias calculadas
      return offices
          .map(
            (office) => {
              ...office,
              'distanceInMiles': -1.0, // Valor de error
            },
          )
          .toList();
    }
  }

  // Método para probar el cálculo de distancias
  Future<void> _testDistanceCalculation() async {
    try {
      // Mostrar diálogo de carga
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Calculando distancias...'),
                ],
              ),
            ),
          );
        },
      );

      // Crear datos de prueba para las oficinas
      final List<Map<String, dynamic>> officesMaps = [
        {
          'id': 'chula_vista',
          'latitude': 32.6024602,
          'longitude': -117.0804273,
          'address': '1295 Broadway #201, Chula Vista, CA 91911',
          'secondaryAddress': 'Suite 201',
          'isOpen': true,
          'closeHours': '18:00',
          'reference': 'Cerca de Target',
          'rating': 4.5,
        },
        {
          'id': 'national_city',
          'latitude': 32.6773538,
          'longitude': -117.0962897,
          'address': '1727 Sweetwater Rd Suite 122, National City, CA 91950',
          'secondaryAddress': 'Suite 122',
          'isOpen': true,
          'closeHours': '18:00',
          'reference': 'Cerca del centro comercial',
          'rating': 4.2,
        },
      ];

      // Calcular distancias usando Geolocator directamente
      final List<Map<String, dynamic>> officesWithDistances =
          await _calculateDistances(officesMaps);

      // Cerrar diálogo de carga y mostrar resultados solo si el widget sigue montado
      if (mounted) {
        Navigator.of(context).pop();
        await _showResultsDialog(officesWithDistances);
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto y mostrar error solo si el widget sigue montado
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // Mostrar error
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error en la prueba'),
              content: Text(
                'Ocurrió un error al ejecutar la prueba: ${e.toString()}',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Método para mostrar los resultados del cálculo de distancias
  Future<void> _showResultsDialog(
    List<Map<String, dynamic>> officesWithDistances,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resultados de Distancias'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: officesWithDistances.length,
              itemBuilder: (context, index) {
                final office = officesWithDistances[index];
                final String id = office['id'] as String;
                final double distance = office['distanceInMiles'] as double;
                final String address = office['address'] as String;

                return ListTile(
                  title: Text('Oficina: $id'),
                  subtitle: Text('Dirección: $address'),
                  trailing: Text(
                    '${distance.toStringAsFixed(2)} mi',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Demo V1'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              child: const Text('Abrir Mapa'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ejecutar prueba de cálculo de distancias
                _testDistanceCalculation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4DA2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Probar Cálculo de Distancias'),
            ),
          ],
        ),
      ),
    );
  }
}
