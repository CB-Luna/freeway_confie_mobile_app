import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/office_location.dart';
import '../../services/directions_service.dart';

class LocationDetailsView extends StatefulWidget {
  final OfficeLocation office;
  final List<OfficeLocation> allOffices;

  const LocationDetailsView({
    required this.office,
    required this.allOffices,
    super.key,
  });

  @override
  State<LocationDetailsView> createState() => _LocationDetailsViewState();
}

class _LocationDetailsViewState extends State<LocationDetailsView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _currentPosition = const LatLng(0, 0);
  String _currentAddress = '';
  String _currentSecondaryAddress = '';
  bool _isMapReady = false;
  BitmapDescriptor? customIcon;

  @override
  void initState() {
    super.initState();
    // Inicialmente usamos la ubicación de la oficina
    _currentPosition = LatLng(widget.office.latitude, widget.office.longitude);
    _currentAddress = widget.office.address;
    _currentSecondaryAddress = widget.office.secondaryAddress;

    // Cargamos el icono personalizado usando un enfoque alternativo
    // para evitar el uso del método obsoleto fromAssetImage
    _loadCustomMarkerFromAsset('assets/prefix.png').then((icon) {
      customIcon = icon;
      _setMarkers();
    });

    // Método anterior (obsoleto)
    // BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(size: Size(48, 48)),
    //   'assets/prefix.png',
    // ).then((icon) {
    //   customIcon = icon;
    //   _setMarkers();
    // });

    // Obtenemos la ubicación actual del dispositivo
    _getCurrentDeviceLocation();
  }

  // Método para obtener la ubicación actual del dispositivo
  Future<void> _getCurrentDeviceLocation() async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log(
          'Los servicios de ubicación están desactivados',
          name: 'LocationDetailsView',
        );
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log(
            'Permiso de ubicación denegado',
            name: 'LocationDetailsView',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log(
          'Permiso de ubicación denegado permanentemente',
          name: 'LocationDetailsView',
        );
        return;
      }

      // Obtener la ubicación actual
      final Position position = await Geolocator.getCurrentPosition();

      // Actualizar la posición actual con la ubicación del dispositivo
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Obtener la dirección para la ubicación actual
        await _getAddressFromLatLng(_currentPosition);

        // Centrar el mapa en la ubicación actual si el controlador está disponible
        if (_mapController != null && _isMapReady) {
          _centerMapOnCurrentLocation();
        }
      }
    } catch (e) {
      developer.log(
        'Error al obtener la ubicación actual: $e',
        name: 'LocationDetailsView',
      );
    }
  }

  void _setMarkers() {
    if (!mounted) return;

    setState(() {
      _markers = {};

      // Marcadores para todas las oficinas con el icono personalizado
      for (var office in widget.allOffices) {
        _markers.add(
          Marker(
            markerId: MarkerId('office_${office.id}'),
            position: LatLng(office.latitude, office.longitude),
            infoWindow: InfoWindow(
              title: office.name,
              snippet: office.address,
            ),
            icon: customIcon ?? BitmapDescriptor.defaultMarker,
          ),
        );
      }

      // Marcador principal (flecha roja) - siempre visible
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_office'),
          position: _currentPosition,
          infoWindow: InfoWindow(
            title: widget.office.name,
            snippet: _currentAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
            });
            _getAddressFromLatLng(newPosition);
          },
        ),
      );
    });
  }

  // Función para obtener la dirección a partir de coordenadas
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      debugPrint(
        'Obteniendo dirección para: ${position.latitude}, ${position.longitude}',
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        debugPrint('Placemark obtenido: $place');

        // Construimos la dirección principal
        String mainAddress = '';
        if (place.street != null && place.street!.isNotEmpty) {
          mainAddress = place.street!;
          if (place.subThoroughfare != null &&
              place.subThoroughfare!.isNotEmpty) {
            mainAddress = '${place.subThoroughfare} $mainAddress';
          }
        } else if (place.thoroughfare != null &&
            place.thoroughfare!.isNotEmpty) {
          mainAddress = place.thoroughfare!;
          if (place.subThoroughfare != null &&
              place.subThoroughfare!.isNotEmpty) {
            mainAddress = '${place.subThoroughfare} $mainAddress';
          }
        } else {
          // Si no hay calle, usamos la dirección formateada
          mainAddress =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        }

        // Construimos la dirección secundaria
        final List<String> secondaryParts = [];
        if (place.locality != null && place.locality!.isNotEmpty) {
          secondaryParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          secondaryParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          secondaryParts.add(place.postalCode!);
        }

        final String secondaryAddress = secondaryParts.join(', ');

        // Actualizamos el estado con las nuevas direcciones
        setState(() {
          _currentAddress = mainAddress;
          _currentSecondaryAddress = secondaryAddress;
          debugPrint(
            'Dirección actualizada: $_currentAddress, $_currentSecondaryAddress',
          );

          // Actualizamos el marcador con la nueva información
          _updateMarkerInfo();
        });
      }
    } catch (e) {
      developer.log(
        'Error obteniendo dirección: $e',
        name: 'LocationDetailsView',
      );
    }
  }

  // Actualiza la información del marcador
  void _updateMarkerInfo() {
    if (!_isMapReady) return;

    debugPrint(
      'Actualizando marcador en: ${_currentPosition.latitude}, ${_currentPosition.longitude}',
    );

    // Eliminamos el marcador existente
    _markers
        .removeWhere((marker) => marker.markerId.value == 'selected_office');

    // Añadimos el nuevo marcador con la posición actualizada
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_office'),
        position: _currentPosition,
        infoWindow: InfoWindow(
          title: widget.office.name,
          snippet: _currentAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          _centerMapOnOffice();
        },
        draggable: true,
        onDragStart: (startPosition) {
          debugPrint(
            'Comenzando a arrastrar desde: ${startPosition.latitude}, ${startPosition.longitude}',
          );
        },
        onDragEnd: (newPosition) {
          debugPrint(
            'Finalizando arrastre en: ${newPosition.latitude}, ${newPosition.longitude}',
          );
          setState(() {
            _currentPosition = newPosition;
          });
          _getAddressFromLatLng(newPosition);
        },
      ),
    );

    // Actualizamos el estado para reflejar los cambios
    setState(() {});
  }

  // Función para centrar el mapa en la oficina seleccionada
  void _centerMapOnOffice() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.office.latitude, widget.office.longitude),
            zoom: 16.0, // Zoom más cercano para ver mejor la ubicación
          ),
        ),
      );
    }
  }

  // Función para centrar el mapa en la ubicación actual del dispositivo
  void _centerMapOnCurrentLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 16.0, // Zoom más cercano para ver mejor la ubicación
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 14.0,
          ),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            setState(() {
              _isMapReady = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                _setMarkers();
                // Centrar el mapa en la ubicación actual en lugar de la oficina
                _centerMapOnCurrentLocation();
              });
            });
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: true,
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'location',
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
            onPressed: () {
              _getCurrentDeviceLocation();
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.office.isOpen ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            color:
                                widget.office.isOpen ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' • Closes at ${widget.office.closeHours}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${widget.office.distanceInMiles.toStringAsFixed(2)} miles',
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.office.address,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.office.secondaryAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.office.reference.isNotEmpty)
                  Text(
                    'Reference: ${widget.office.reference}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.call, color: Colors.blue),
                        label: const Text('Call Office'),
                        onPressed: () {
                          _callOffice();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                        onPressed: () {
                          _getDirections();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.office.rating > 0)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      Text(
                        ' ${widget.office.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // Implementar búsqueda de otras oficinas
                    _findOtherOffices();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Find Other Offices',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Método para cargar un icono de marcador personalizado desde un activo
  // Este método evita el uso del método obsoleto fromAssetImage
  Future<BitmapDescriptor> _loadCustomMarkerFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }

  // Método para obtener direcciones a la oficina seleccionada
  void _getDirections() {
    // Utilizamos el servicio de direcciones para navegar a la oficina
    // El servicio se encarga de verificar permisos, detectar disponibilidad de geolocalización
    // y abrir Google Maps con la ruta desde la ubicación actual hasta la oficina
    DirectionsService.navigateToOffice(context, widget.office);
  }

  // Método para buscar otras oficinas cercanas
  void _findOtherOffices() {
    // Aquí podríamos implementar la navegación a una página de búsqueda de oficinas
    // Por ahora, simplemente mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buscando otras oficinas cercanas...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Método para llamar a la oficina
  void _callOffice() async {
    // Suponemos que el número de teléfono está en el formato '123-456-7890'
    // Para propósitos de prueba, usamos un número fijo
    final String phoneNumber = '800-777-5620'; // Número de Freeway Insurance

    // Construir la URI para la llamada telefónica
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      // Intentar lanzar la aplicación de teléfono
      final bool launched = await launchUrl(uri);
      if (!launched) {
        _showErrorSnackBar();
      }
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  // Método auxiliar para mostrar un mensaje de error
  void _showErrorSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo iniciar la llamada. Por favor, intente más tarde.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
