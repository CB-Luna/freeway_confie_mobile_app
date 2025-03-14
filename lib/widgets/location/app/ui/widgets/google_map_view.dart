import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget que encapsula el GoogleMap para simplificar su integración
/// y permitir configurar estilos de manera más declarativa
class GoogleMapView extends StatefulWidget {
  final Function(GoogleMapController) onMapCreated;
  final CameraPosition initialPosition;
  final Set<Marker> markers;
  final Function(LatLng) onTap;
  final MapType mapType;
  final String? customMapStyle;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;

  const GoogleMapView({
    required this.onMapCreated,
    required this.initialPosition,
    required this.markers,
    required this.onTap,
    super.key,
    this.mapType = MapType.normal,
    this.customMapStyle,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
  });

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  void _onMapCreated(GoogleMapController controller) {
    widget.onMapCreated(controller);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: widget.initialPosition,
      markers: widget.markers,
      onTap: widget.onTap,
      mapType: widget.mapType,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      style: widget.customMapStyle,
    );
  }
}
