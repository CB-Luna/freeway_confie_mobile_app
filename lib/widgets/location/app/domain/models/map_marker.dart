import 'dart:ui' show Offset;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerModel {
  final String id;
  LatLng position;
  final String title;
  final String snippet;
  final BitmapDescriptor icon;
  final Function(MarkerId, LatLng)? onDragEnd;
  final bool visible;
  final double zIndex;

  MapMarkerModel({
    required this.id,
    required this.position,
    required this.title,
    required this.snippet,
    required this.icon,
    this.onDragEnd,
    this.visible = true,
    this.zIndex = 1.0,
  });

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: icon,
      // Ajustando el punto de ancla para que coincida con la parte inferior de la imagen
      anchor: const Offset(0.5, 1.0),
      draggable:
          onDragEnd != null, // Solo arrastrable si hay un callback definido
      onDragEnd: (newPosition) {
        position = newPosition;
        if (onDragEnd != null) {
          onDragEnd!(MarkerId(id), newPosition);
        }
      },
      visible: visible, // Controlar la visibilidad del marcador
      zIndex: zIndex, // Controlar la prioridad de visualización
    );
  }
}
