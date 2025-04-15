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
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Ajustar el padding según el tamaño de la pantalla
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    
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

          // Contenido principal
          if (showNoNearbyOfficesView) 
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
            )
          else if (offices.isEmpty)
            // Cuando la lista de oficinas está vacía
            Expanded(
              child: Center(
                child: Text(context.translate('office.noOfficesAvailable')),
              ),
            )
          else
            // Cuando hay oficinas para mostrar
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                // Incrementamos el itemCount en 2: uno para el título y otro para el espacio/botón al final
                itemCount: offices.length + 2,
                itemBuilder: (context, index) {
                  // Primer elemento es el título
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            context.translate('office.nearestOffice'),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextGreyColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  
                  // Ajustamos el índice para los elementos de la oficina (restamos 1 por el título)
                  final adjustedIndex = index - 1;
                  
                  // Si es el último elemento (después de todas las oficinas)
                  if (adjustedIndex == offices.length) {
                    if (offices.length == 1) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: isSmallScreen ? 12.0 : 16.0,
                          bottom: isSmallScreen ? 16.0 : 24.0,
                        ),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: onViewAllOffices,
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                            ),
                            label: Text(
                              context.translate(
                                'office.findOtherOffices',
                              ),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12.0 : 16.0,
                                vertical: isSmallScreen ? 6.0 : 8.0,
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
                  final office = offices[adjustedIndex];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (adjustedIndex > 0) const Divider(),
                      OfficeListItem(
                        office: office,
                        index: adjustedIndex,
                        onTap: () => onOfficeTap(office),
                        onDirectionsTap: () => onOfficeTap(office),
                      ),
                    ],
                  );
                },
              ),
            ),
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
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Ajustar tamaños de fuente y espaciado según el tamaño de la pantalla
    final smallFontSize = isSmallScreen ? 10.0 : 12.0;
    final mediumFontSize = isSmallScreen ? 12.0 : 14.0;
    final buttonPaddingH = isSmallScreen ? 10.0 : 16.0;
    final buttonPaddingV = isSmallScreen ? 8.0 : 12.0;
    final buttonSpacing = isSmallScreen ? 8.0 : 12.0;
    
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${context.translate('office.openNow')} • ${context.translateWithArgs(
                'office.closesAt',
                args: [
                  '7pm',
                ],
              )}',
              style: TextStyle(
                color: AppTheme.getGreenColor(context),
                fontWeight: FontWeight.bold,
                fontSize: smallFontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${office.distance.toStringAsFixed(2)} ${context.translate('office.miles')}',
            style: TextStyle(
              color: AppTheme.getBlueColor(context),
              fontWeight: FontWeight.bold,
              fontSize: smallFontSize,
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
              fontSize: mediumFontSize,
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
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.getYellowColor(context),
                    size: isSmallScreen ? 14 : 18,
                  ),
                  Text(
                    '4.5',
                    style: TextStyle(
                      fontSize: mediumFontSize,
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
                  icon: Icon(
                    Icons.phone_in_talk_outlined,
                    color: AppTheme.white,
                    size: isSmallScreen ? 18 : 24,
                  ),
                  label: Text(context.translate('office.callOffice')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.getPrimaryColor(context), // Azul oscuro
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPaddingH,
                      vertical: buttonPaddingV,
                    ),
                  ),
                ),
                SizedBox(width: buttonSpacing),

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
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPaddingH,
                      vertical: buttonPaddingV,
                    ),
                  ),
                ),
                SizedBox(width: buttonSpacing),

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
                        SnackBar(
                          content: Text(
                            context.translate('office.couldNotOpenMaps'),
                          ),
                          backgroundColor: AppTheme.getRedColor(context),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPaddingH,
                      vertical: buttonPaddingV,
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
