import 'package:flutter/material.dart';

class NoNearbyOfficesView extends StatelessWidget {
  final VoidCallback onExpandSearchRadius;
  final VoidCallback onViewAllOffices;

  const NoNearbyOfficesView({
    required this.onExpandSearchRadius,
    required this.onViewAllOffices,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // // Mensaje de error con ícono
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(10),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 5,
          //         spreadRadius: 1,
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       const Icon(
          //         Icons.warning_amber_rounded,
          //         color: Colors.orange,
          //         size: 24,
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Text(
          //           "We're sorry, we were unable to find a location near you",
          //           style: TextStyle(
          //             color: Colors.orange[700],
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 12),

          // Mensaje informativo
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "No nearby locations found, but we've got you covered! You can:",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón para expandir el radio de búsqueda
          OutlinedButton.icon(
            onPressed: onExpandSearchRadius,
            icon: const Icon(
              Icons.search,
              color: Color(0xFF0A4DA2),
            ),
            label: const Text(
              'Expand your search radius',
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
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón para ver todas las oficinas
          OutlinedButton.icon(
            onPressed: onViewAllOffices,
            icon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF0A4DA2),
            ),
            label: const Text(
              'View All our Offices',
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
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón de ayuda
          ElevatedButton.icon(
            onPressed: () {
              // Acción para el botón de ayuda
            },
            icon: const Icon(
              Icons.phone_in_talk_outlined,
              color: Colors.white,
            ),
            label: const Text('Help'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A4DA2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mensaje de cobertura nacional
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Freeway serves all 50 states—wherever you are, we're here for your insurance needs!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
