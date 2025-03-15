import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/office.dart';

class MapWidget extends StatefulWidget {
  final Location location;
  final List<Office>? offices;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function(CameraPosition)? onCameraMove;
  final void Function(LatLng)? onTap;
  final bool zoomControlsEnabled;
  final bool myLocationButtonEnabled;
  final double initialZoom;

  const MapWidget({
    required this.location,
    super.key,
    this.offices,
    this.onMapCreated,
    this.onCameraMove,
    this.onTap,
    this.zoomControlsEnabled = true,
    this.myLocationButtonEnabled = false,
    this.initialZoom = 14.0,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};

    // Marcador de la ubicación actual
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(widget.location.latitude, widget.location.longitude),
        infoWindow: const InfoWindow(
          title: 'Mi ubicación',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Marcadores de las oficinas
    if (widget.offices != null) {
      for (var office in widget.offices!) {
        markers.add(
          Marker(
            markerId: MarkerId('office_${office.id}'),
            position: LatLng(office.latitude, office.longitude),
            infoWindow: InfoWindow(
              title: office.name,
              snippet: office.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.location.latitude, widget.location.longitude),
        zoom: widget.initialZoom,
      ),
      markers: _createMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: true,
      compassEnabled: true,
      trafficEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
      onCameraMove: widget.onCameraMove,
      onTap: widget.onTap,
    );
  }
}
