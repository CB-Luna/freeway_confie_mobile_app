import 'package:flutter/material.dart';

class MapControlButtons extends StatelessWidget {
  final VoidCallback onChangeStylePressed;
  final VoidCallback onToggleMarkerModePressed;
  final VoidCallback onClearMarkersPressed;
  final bool markerModeActive;

  const MapControlButtons({
    required this.onChangeStylePressed,
    required this.onToggleMarkerModePressed,
    required this.onClearMarkersPressed,
    required this.markerModeActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Botón para cambiar el estilo del mapa
          Tooltip(
            message: 'Change map style',
            child: FloatingActionButton(
              onPressed: onChangeStylePressed,
              heroTag: 'btn1',
              child: const Icon(Icons.map),
            ),
          ),
          const SizedBox(height: 10),

          // Botón para activar/desactivar el modo de marcadores
          Tooltip(
            message: 'Toggle marker mode',
            child: FloatingActionButton(
              onPressed: onToggleMarkerModePressed,
              backgroundColor: markerModeActive ? Colors.blue : Colors.grey,
              heroTag: 'btn2',
              child: const Icon(Icons.add_location),
            ),
          ),
          const SizedBox(height: 10),

          // Botón para eliminar todos los marcadores
          Tooltip(
            message: 'Clear all markers',
            child: FloatingActionButton(
              onPressed: onClearMarkersPressed,
              backgroundColor: Colors.red,
              heroTag: 'btn3',
              child: const Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }
}
