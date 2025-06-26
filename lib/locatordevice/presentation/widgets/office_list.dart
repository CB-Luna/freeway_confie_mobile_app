import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'
    show launchUrl, canLaunchUrl, LaunchMode;

import '../../../data/models/office/office.dart';
import '../controllers/location_controller.dart';
import 'no_nearby_offices_view.dart';

class OfficeList extends StatefulWidget {
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
  State<OfficeList> createState() => _OfficeListState();
}

class _OfficeListState extends State<OfficeList> {
  final TextEditingController _zipController = TextEditingController();
  final FocusNode _zipFocusNode = FocusNode();

  @override
  void dispose() {
    _zipController.dispose();
    _zipFocusNode.dispose();
    super.dispose();
  }

  void _searchByZipCode() {
    final zipCode = _zipController.text.trim();

    // Validar que el código postal tenga 5 dígitos
    if (zipCode.isEmpty ||
        zipCode.length != 5 ||
        !RegExp(r'^[0-9]{5}$').hasMatch(zipCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.translate('office.zipCode.invalidZipCode'),
            style: TextStyle(
              fontSize: responsiveFontSizes.snackBarText(context),
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.getRedColor(context),
        ),
      );
      return;
    }

    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Obtener el controlador de ubicación
    final locationController = Provider.of<LocationController>(
      context,
      listen: false,
    );

    // Mostrar un mensaje al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.translateWithArgs(
            'office.zipCode.searchingNear',
            args: [zipCode],
          ),
          style: TextStyle(
            fontSize: responsiveFontSizes.snackBarText(context),
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.getBlueColor(context),
      ),
    );

    // Llamar al método de búsqueda por código postal
    locationController.searchByZipCode(zipCode, context);
  }

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
          if (widget.showNoNearbyOfficesView)
            // Contenido cuando no hay oficinas cercanas
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: NoNearbyOfficesView(
                    onExpandSearchRadius: widget.onExpandSearchRadius ?? () {},
                    onViewAllOffices: widget.onViewAllOffices ?? () {},
                  ),
                ),
              ),
            )
          else
            // Cuando hay oficinas para mostrar
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                // Incrementamos el itemCount en 2: uno para el título y otro para el espacio/botón al final
                itemCount: widget.offices.length +
                    3, // +3: título, espacio/botón al final, y sección de búsqueda por zipcode
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
                              fontSize: responsiveFontSizes.bodyLarge(context),
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
                  if (adjustedIndex == widget.offices.length) {
                    if (widget.offices.length == 1) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: isSmallScreen ? 12.0 : 16.0,
                          bottom: isSmallScreen ? 16.0 : 24.0,
                        ),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: widget.onViewAllOffices,
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
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
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

                  // Si es el penúltimo elemento (después de todas las oficinas y el espacio/botón), mostrar la sección de búsqueda por zipcode
                  if (adjustedIndex == widget.offices.length + 1) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 32),
                        // Título de la sección
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 16.0, top: 8.0),
                          child: Text(
                            context.translate(
                              'office.zipCode.searchOfficeByZipcode',
                            ),
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodyMedium(context),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextGreyColor(context),
                            ),
                          ),
                        ),

                        // Diseño más compacto con campo de entrada y botón en la misma fila
                        Row(
                          children: [
                            // Campo de entrada de código postal (más pequeño)
                            Expanded(
                              flex: 5,
                              child: SizedBox(
                                height: isSmallScreen ? 40 : 44,
                                child: TextField(
                                  controller: _zipController,
                                  focusNode: _zipFocusNode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  style: TextStyle(
                                    fontSize:
                                        responsiveFontSizes.bodyMedium(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: context.translate(
                                      'office.zipCode.zipCodeHint',
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: responsiveFontSizes
                                          .bodyMedium(context),
                                    ),
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppTheme.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: isSmallScreen ? 8 : 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: AppTheme.getDetailsGreyColor(
                                          context,
                                        ),
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color:
                                            AppTheme.getPrimaryColor(context),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Botón de búsqueda (más pequeño y con icono)
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: isSmallScreen ? 40 : 44,
                                child: ElevatedButton.icon(
                                  onPressed: _searchByZipCode,
                                  icon: Icon(
                                    Icons.search,
                                    size: isSmallScreen ? 16 : 18,
                                  ),
                                  label: Text(
                                    context.translate('office.zipCode.search'),
                                    style: TextStyle(
                                      fontSize: responsiveFontSizes
                                          .bodyMedium(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.getPrimaryColor(context),
                                    foregroundColor: AppTheme.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }

                  // Si no es el último ni el penúltimo elemento, mostrar el elemento de la oficina
                  final office = widget.offices[adjustedIndex];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (adjustedIndex > 0) const Divider(),
                      OfficeListItem(
                        office: office,
                        index: adjustedIndex,
                        onTap: () => widget.onOfficeTap(office),
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

  const OfficeListItem({
    required this.office,
    required this.index,
    required this.onTap,
    super.key,
  });

  // Método para obtener el nombre del día de la semana actual
  String _getDayOfWeek(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;

    // En Dart: weekday va de 1 (lunes) a 7 (domingo)
    // Organizamos los arrays para que coincidan con este orden
    const daysEn = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const daysEs = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    // Obtenemos el índice correcto (0-6)
    final index = now.weekday - 1;

    return locale.startsWith('es') ? daysEs[index] : daysEn[index];
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Ajustar tamaños de fuente y espaciado según el tamaño de la pantalla
    final smallFontSize = responsiveFontSizes.bodySmall(context);
    final mediumFontSize = responsiveFontSizes.bodyMedium(context);
    final buttonPaddingH = isSmallScreen ? 10.0 : 16.0;
    final buttonPaddingV = isSmallScreen ? 8.0 : 12.0;
    final buttonSpacing = isSmallScreen ? 8.0 : 12.0;

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '• ${context.translate('office.openNow')}',
              style: TextStyle(
                color: AppTheme.getGreenColor(context),
                fontWeight: FontWeight.bold,
                fontSize: smallFontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${office.distanceObj.value.toStringAsFixed(1)} ${office.distanceObj.unitType}',
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
          Wrap(
            children: [
              Text(
                office.name,
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Horario
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: AppTheme.getTextGreyColor(context),
                size: isSmallScreen ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                context.translateWithArgs(
                  'office.todayHours',
                  args: [
                    _getDayOfWeek(context),
                    '08:00am',
                    '08:00pm',
                  ],
                ),
                style: TextStyle(
                  fontSize: smallFontSize,
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                  label: Text(
                    context.translate('office.callOffice'),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.buttonTextLocation(context),
                    ),
                  ),
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
                            style: TextStyle(
                              fontSize:
                                  responsiveFontSizes.snackBarText(context),
                            ),
                          ),
                          backgroundColor: AppTheme.getRedColor(context),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.directions,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                  label: Text(
                    context.translate('office.getDirections'),
                    style: TextStyle(
                      color: AppTheme.getPrimaryColor(context),
                      fontSize: responsiveFontSizes.buttonTextLocation(context),
                    ),
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
