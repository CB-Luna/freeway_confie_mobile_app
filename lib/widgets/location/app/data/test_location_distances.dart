import 'package:flutter/material.dart';

import '../../../location/app/data/office_data.dart';
import '../../../location/app/domain/models/office_location.dart';
import '../../../location/app/ui/utils/distance_calculator.dart';

/// Clase para probar el cálculo de distancias de oficinas
class TestLocationDistances {
  /// Ejecuta una prueba de cálculo de distancias desde la ubicación actual
  /// a las oficinas de Freeway Insurance
  static Future<void> runTest(BuildContext context) async {
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

      // Obtener las oficinas
      final List<OfficeLocation> offices = OfficeData.getOffices();

      // Convertir oficinas a formato de mapa para el cálculo de distancias
      final List<Map<String, dynamic>> officesMaps = offices
          .map(
            (office) => {
              'id': office.id,
              'latitude': office.latitude,
              'longitude': office.longitude,
              'address': office.address,
              'secondaryAddress': office.secondaryAddress,
              'isOpen': office.isOpen,
              'closeHours': office.closeHours,
              'reference': office.reference,
              'rating': office.rating,
            },
          )
          .toList();

      // Ejecutar prueba de cálculo de distancias
      await DistanceCalculator.testOfficeDistances(officesMaps);

      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar resultados
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Prueba completada'),
              content: const Text(
                'La prueba de cálculo de distancias se ha completado. Revisa la consola para ver los resultados.',
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
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      if (context.mounted) {
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
}
