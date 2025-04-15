import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';

class MapButtons extends StatelessWidget {
  final VoidCallback onLocationPressed;
  final VoidCallback onToggleListPressed;

  const MapButtons({
    required this.onLocationPressed,
    required this.onToggleListPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho y alto de la pantalla para cálculos responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isShortScreen = screenSize.height < 700;
    
    // Ajustar el tamaño de los botones y el espaciado según el tamaño de la pantalla
    final buttonSize = isSmallScreen ? 46.0 : 56.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final spacing = isSmallScreen ? 8.0 : 16.0;
    
    // Ajustar la posición según el tamaño de la pantalla
    final rightPadding = isSmallScreen ? 8.0 : 16.0;
    final bottomPadding = isShortScreen ? 140.0 : 180.0;
    
    return Positioned(
      right: rightPadding,
      bottom: bottomPadding,
      child: Column(
        children: [
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              backgroundColor: Colors.white,
              onPressed: onLocationPressed,
              tooltip: context.translate('office.findNearby'),
              child: Icon(Icons.my_location, color: Colors.blue, size: iconSize),
            ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: FloatingActionButton(
              heroTag: 'toggleList',
              backgroundColor: Colors.white,
              onPressed: onToggleListPressed,
              tooltip: context.translate('office.viewAllOffices'),
              child: Icon(Icons.list, color: Colors.blue, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}
