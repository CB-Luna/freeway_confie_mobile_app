import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
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
    // Eliminamos el SingleChildScrollView anidado ya que ya tenemos uno en OfficeList
    return Column(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            context.translate('office.noNearbyLocations'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextGreyColor(context),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Botón para expandir el radio de búsqueda
        OutlinedButton.icon(
          onPressed: onExpandSearchRadius,
          icon: Icon(
            Icons.search,
            color: AppTheme.getPrimaryColor(context),
          ),
          label: Text(
            context.translate('office.expandSearchRadius'),
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
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Botón para ver todas las oficinas
        OutlinedButton.icon(
          onPressed: onViewAllOffices,
          icon: Icon(
            Icons.location_on_outlined,
            color: AppTheme.getPrimaryColor(context),
          ),
          label: Text(
            context.translate('office.viewAllOffices'),
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
            color: AppTheme.white,
          ),
          label: Text(context.translate('office.help')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.getPrimaryColor(context),
            foregroundColor: AppTheme.white,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            context.translate('office.nationalCoverage'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextGreyColor(context),
            ),
          ),
        ),
        // Añadir espacio adicional al final para permitir desplazamiento completo
        const SizedBox(height: 24),
      ],
    );
  }
}
