import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

import '../../pages/webview_page.dart';

class RoadsideHelp extends StatefulWidget {
  const RoadsideHelp({super.key});

  @override
  State<RoadsideHelp> createState() => _RoadsideHelpState();
}

class _RoadsideHelpState extends State<RoadsideHelp>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppTheme.getCardColor(context),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WebViewPage(
                url: 'https://buy.freeway.com/product/auto-club/step-1',
                title: 'Freeway Auto Club',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: screenWidth - 48, // Ancho adaptable
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 6, // Dar más espacio al texto
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.translate('home.roadsideHelp.needHelp'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextGreyColor(context),
                      ),
                      maxLines: 2, // Permitir hasta 2 líneas si es necesario
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.translate('home.roadsideHelp.addAutoClub'),
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(context),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 18 / 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Contenedor para el botón animado
              Flexible(
                flex: 4, // Dar menos espacio a la imagen
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.getBackgroundColor(context),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/home/icons/truckwhite.png',
                        width: 60, // Reducido ligeramente
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8), // Reducido
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.getDetailsGreyColor(context),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
