import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/contactcenter/request_call.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

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
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Ajustar tamaños de fuente y espaciado según el tamaño de la pantalla
    final textFontSize = responsiveFontSizes.bodyTextLocation(context);
    final buttonFontSize = responsiveFontSizes.buttonTextLocation(context);
    final buttonPaddingH = isSmallScreen ? 16.0 : 20.0;
    final buttonPaddingV = isSmallScreen ? 10.0 : 12.0;
    final buttonSpacing = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 18.0 : 24.0;
    final helpButtonPaddingH = isSmallScreen ? 30.0 : 40.0;
    final helpButtonPaddingV = isSmallScreen ? 12.0 : 16.0;

    // Eliminamos el SingleChildScrollView anidado ya que ya tenemos uno en OfficeList
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mensaje informativo
        Padding(
          padding: EdgeInsets.symmetric(horizontal: buttonPaddingH),
          child: Text(
            context.translate('office.noNearbyLocations'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textFontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextGreyColor(context),
            ),
          ),
        ),
        SizedBox(height: buttonSpacing),

        // Botón para expandir el radio de búsqueda
        OutlinedButton.icon(
          onPressed: onExpandSearchRadius,
          icon: Icon(
            Icons.search,
            color: AppTheme.getPrimaryColor(context),
            size: iconSize,
          ),
          label: Text(
            context.translate('office.expandSearchRadius'),
            style: TextStyle(
              color: AppTheme.getPrimaryColor(context),
              fontSize: buttonFontSize,
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
        SizedBox(height: buttonSpacing),

        // Botón para ver todas las oficinas
        OutlinedButton.icon(
          onPressed: onViewAllOffices,
          icon: Icon(
            Icons.location_on_outlined,
            color: AppTheme.getPrimaryColor(context),
            size: iconSize,
          ),
          label: Text(
            context.translate('office.viewAllOffices'),
            style: TextStyle(
              color: AppTheme.getPrimaryColor(context),
              fontSize: buttonFontSize,
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
        SizedBox(height: buttonSpacing),

        // Botón de ayuda
        ElevatedButton.icon(
          onPressed: () {
            // Método para navegar a la página de contacto del agente
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RequestCallPage(),
              ),
            );
          },
          icon: Icon(
            Icons.phone_in_talk_outlined,
            color: AppTheme.white,
            size: iconSize,
          ),
          label: Text(
            context.translate('office.help'),
            style: TextStyle(
              fontSize: buttonFontSize,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.getPrimaryColor(context),
            foregroundColor: AppTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: helpButtonPaddingH,
              vertical: helpButtonPaddingV,
            ),
          ),
        ),
        SizedBox(height: buttonSpacing),

        // Mensaje de cobertura nacional
        Padding(
          padding: EdgeInsets.symmetric(horizontal: buttonPaddingH),
          child: Text(
            context.translate('office.nationalCoverage'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textFontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextGreyColor(context),
            ),
          ),
        ),
        // Añadir espacio adicional al final para permitir desplazamiento completo
        SizedBox(height: isSmallScreen ? 16 : 24),
      ],
    );
  }
}
