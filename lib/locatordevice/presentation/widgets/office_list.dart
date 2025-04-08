import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart'
    show launchUrl, canLaunchUrl, LaunchMode;

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
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getBoxShadowColor(context),
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
                color: AppTheme.getDetailsGreyColor(context),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                context.translate('office.nearestOffice'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Lista de oficinas
            Expanded(
              child: offices.isEmpty
                  ? Center(
                      child:
                          Text(context.translate('office.noOfficesAvailable')))
                  : CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // Si es el último elemento y solo hay una oficina,
                                // mostrar el botón "Find other offices"
                                if (index == offices.length) {
                                  if (offices.length == 1) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16.0,
                                        bottom: 24.0,
                                      ),
                                      child: Center(
                                        child: TextButton.icon(
                                          onPressed: onViewAllOffices,
                                          icon: Icon(
                                            Icons.search,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          label: Text(
                                            context.translate(
                                                'office.findOtherOffices'),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 8.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  // Si hay más de una oficina, solo añadir espacio adicional
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
                                      onDirectionsTap: () =>
                                          onOfficeTap(office),
                                    ),
                                  ],
                                );
                              },
                              childCount: offices.length +
                                  1, // +1 para el espacio adicional o el botón
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
          Text(
            '${context.translate('office.openNow')} • ${context.translateWithArgs('office.closesAt', args: [
                  '7pm'
                ])}',
            style: TextStyle(
              color: AppTheme.getGreenColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '${office.distance.toStringAsFixed(2)} ${context.translate('office.miles')}',
            style: TextStyle(
              color: AppTheme.getBlueColor(context),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTitleTextColor(context),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                office.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.getYellowColor(context),
                    size: 18,
                  ),
                  const Text(
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
                    color: AppTheme.white,
                  ),
                  label: Text(context.translate('office.callOffice')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.getPrimaryColor(context), // Azul oscuro
                    foregroundColor: AppTheme.white,
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
                  icon: Icon(
                    Icons.directions,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                  label: Text(
                    context.translate('office.getDirections'),
                    style: TextStyle(color: AppTheme.getPrimaryColor(context)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.getPrimaryColor(context),
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
                const SizedBox(width: 12),

                // Botón para abrir en Maps (GoogleMaps o Apple Maps)
                OutlinedButton.icon(
                  onPressed: () async {
                    // Obtener la latitud y longitud de la oficina
                    final lat = office.latitude;
                    final lng = office.longitude;
                    final name = Uri.encodeComponent(office.name);

                    // Crear la URL para abrir en mapas según la plataforma
                    String url;
                    if (Theme.of(context).platform == TargetPlatform.iOS) {
                      // URL para Apple Maps (iOS)
                      url = 'https://maps.apple.com/?q=$name&ll=$lat,$lng';
                    } else {
                      // URL para Google Maps (Android y otros)
                      url =
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                    }

                    // Abrir la URL
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      // Mostrar un mensaje de error si no se puede abrir la URL
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open maps application'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.map,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                  label: Text(
                    context.translate('office.viewInMaps'),
                    style: TextStyle(color: AppTheme.getPrimaryColor(context)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.getPrimaryColor(context),
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
