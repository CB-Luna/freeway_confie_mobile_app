import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/office.dart';

class MapWidget extends StatelessWidget {
  final Location location;
  final List<Office>? offices;

  const MapWidget({
    required this.location,
    super.key,
    this.offices,
  });

  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};

    // Marcador de la ubicación actual
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: const InfoWindow(
          title: 'Mi ubicación',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Marcadores de las oficinas
    if (offices != null) {
      for (var office in offices!) {
        markers.add(
          Marker(
            markerId: MarkerId('office_${office.id}'),
            position: LatLng(office.latitude, office.longitude),
            infoWindow: InfoWindow(
              title: office.name,
              snippet: office.address,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        target: LatLng(location.latitude, location.longitude),
        zoom: 14,
      ),
      markers: _createMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }
}
