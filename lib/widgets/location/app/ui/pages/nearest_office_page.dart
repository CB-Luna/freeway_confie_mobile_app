import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/office_location.dart';

class NearestOfficePage extends StatelessWidget {
  final OfficeLocation nearestOffice;
  final double userLatitude;
  final double userLongitude;

  const NearestOfficePage({
    required this.nearestOffice, required this.userLatitude, required this.userLongitude, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Office'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              // Tarjeta con información de la oficina
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Estado y distancia
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Open Now • Closes at ${nearestOffice.closeHours}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${nearestOffice.distanceInMiles.toStringAsFixed(2)} miles',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Dirección principal (sin etiqueta)
                        Text(
                          nearestOffice.address,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nearestOffice.secondaryAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Coordenadas
                        const Text(
                          'Coordinates:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latitude: ${nearestOffice.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Longitude: ${nearestOffice.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 16),

                        // Botones de acción con el estilo especificado
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Botón para llamar
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Acción para llamar a la oficina
                                  launchUrl(Uri.parse('tel:+1234567890'));
                                },
                                icon: const Icon(
                                  Icons.phone_in_talk_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text('Call Office'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF0A4DA2,
                                  ), // Azul oscuro
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Botón para obtener direcciones
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Acción para obtener direcciones desde la ubicación del usuario
                                  final url =
                                      'https://www.google.com/maps/dir/?api=1'
                                      '&origin=$userLatitude,$userLongitude'
                                      '&destination=${nearestOffice.latitude},${nearestOffice.longitude}';
                                  launchUrl(Uri.parse(url));
                                },
                                icon: const Icon(
                                  Icons.directions,
                                  color: Color(0xFF0A4DA2),
                                ),
                                label: const Text(
                                  'Get Directions',
                                  style: TextStyle(color: Color(0xFF0A4DA2)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF0A4DA2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Botón para regresar al mapa
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4DA2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Back to Map', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
