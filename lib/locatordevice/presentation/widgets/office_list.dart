import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../../../data/models/office/office.dart';
import 'no_nearby_offices_view.dart';

class OfficeList extends StatelessWidget {
  final List<Office> offices;
  final ScrollController scrollController;
  final Function(Office) onOfficeTap;
  final VoidCallback? onExpandSearchRadius;
  final VoidCallback? onViewAllOffices;
  final bool showNoNearbyOfficesView;

  const OfficeList({
    required this.offices,
    required this.scrollController,
    required this.onOfficeTap,
    this.onExpandSearchRadius,
    this.onViewAllOffices,
    this.showNoNearbyOfficesView = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de arrastre
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Si showNoNearbyOfficesView es true, mostrar el mensaje de no hay oficinas cercanas
          if (showNoNearbyOfficesView) ...[
            // Contenido cuando no hay oficinas cercanas
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: NoNearbyOfficesView(
                    onExpandSearchRadius: onExpandSearchRadius ?? () {},
                    onViewAllOffices: onViewAllOffices ?? () {},
                  ),
                ),
              ),
            ),
          ] else ...[
            // Título
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Nearest Office',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Lista de oficinas
            Expanded(
              child: offices.isEmpty
                  ? const Center(child: Text('No hay oficinas disponibles'))
                  : CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // Si es el último elemento, añadir espacio adicional al final
                                if (index == offices.length) {
                                  return const SizedBox(height: 24);
                                }
                                
                                // Si no es el último elemento, mostrar el elemento de la oficina
                                final office = offices[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (index > 0) const Divider(),
                                    OfficeListItem(
                                      office: office,
                                      index: index,
                                      onTap: () => onOfficeTap(office),
                                      onDirectionsTap: () => onOfficeTap(office),
                                    ),
                                  ],
                                );
                              },
                              childCount: offices.length + 1, // +1 para el espacio adicional
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class OfficeListItem extends StatelessWidget {
  final Office office;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDirectionsTap;

  const OfficeListItem({
    required this.office,
    required this.index,
    required this.onTap,
    required this.onDirectionsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Open Now • Closes at 7pm',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '${office.distance.toStringAsFixed(2)} miles',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            office.streetAddress,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                office.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xFFFFC73C),
                    size: 18,
                  ),
                  Text(
                    '4.5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Botón para llamar
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para llamar a la oficina
                    launchUrl(Uri.parse('tel:${office.phone}'));
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
                  onPressed: onDirectionsTap,
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
      isThreeLine: true,
      onTap: onTap,
    );
  }
}
