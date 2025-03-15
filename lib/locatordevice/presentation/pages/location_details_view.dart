import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/datasources/office_datasource.dart';
import '../../domain/usecases/get_current_location.dart';

class LocationDetailsView extends StatefulWidget {
  const LocationDetailsView({super.key});

  @override
  State<LocationDetailsView> createState() => _LocationDetailsViewState();
}

class _LocationDetailsViewState extends State<LocationDetailsView> {
  late GetCurrentLocation _getCurrentLocation;
  Position? _currentPosition;
  List<Map<String, dynamic>> _offices = [];
  bool _isLoading = true;
  String? _errorMessage;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final OfficeDataSource _officeDataSource = OfficeDataSourceImpl();
  
  // Controlador para el DraggableScrollableSheet
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  
  // Suscripción para actualizar la ubicación en tiempo real
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Para evitar múltiples actualizaciones de marcadores
  bool _markersUpdated = false;
  
  // Detectar si se está usando una ubicación simulada
  bool _isEmulatorOrSimulator = false;
  
  @override
  void initState() {
    super.initState();
    _detectIfEmulator();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDependencies();
    });
  }

  // Método para detectar si se está usando un emulador
  Future<void> _detectIfEmulator() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await Geolocator.getLastKnownPosition();
        // Las coordenadas 37.42, -122.08 son típicas de un emulador Android
        if (androidInfo != null && 
            (androidInfo.latitude - 37.42).abs() < 0.1 && 
            (androidInfo.longitude - (-122.08)).abs() < 0.1) {
          setState(() {
            _isEmulatorOrSimulator = true;
          });
          debugPrint('Se detectó que es un emulador Android con ubicación simulada');
        }
      } else if (Platform.isIOS) {
        // Para iOS, podríamos usar alguna lógica similar en el futuro
        // Por ahora solo mostramos un mensaje de debug
        debugPrint('Dispositivo iOS detectado');
      }
    } catch (e) {
      debugPrint('Error al detectar si es emulador: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      setState(() {
        _errorMessage = 'Missing dependencies';
        _isLoading = false;
      });
      return;
    }
    _getCurrentLocation = args['getCurrentLocation'] as GetCurrentLocation;
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      // Primero habilitamos los servicios de ubicación y solicitamos permisos
      await _checkAndRequestLocationPermission();
      
      // Obtenemos la ubicación actual una primera vez
      final position = await _getCurrentLocation.execute();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      
      // Si detectamos que es un emulador, mostramos un SnackBar informativo
      if (_isEmulatorOrSimulator && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usando ubicación simulada. Las distancias pueden no ser precisas.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
      
      // Iniciamos el rastreo en tiempo real de la ubicación
      _startLocationTracking();
      
      // Actualizamos la posición del mapa
      _updateMapPosition();
      
      // Cargamos las oficinas
      await _loadOffices();
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not determine your location: $e';
        _isLoading = false;
      });
    }
  }

  // Función para verificar y solicitar permisos de ubicación
  Future<void> _checkAndRequestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si los servicios de ubicación están desactivados, mostramos un mensaje
      setState(() {
        _errorMessage = 'Location services are disabled. Please enable them.';
        _isLoading = false;
      });
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied';
          _isLoading = false;
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied. Please enable them in settings.';
        _isLoading = false;
      });
      return Future.error('Location permissions are permanently denied');
    }
  }

  // Función para iniciar el seguimiento de ubicación en tiempo real
  void _startLocationTracking() {
    // Cancelamos cualquier suscripción anterior
    _positionStreamSubscription?.cancel();
    
    // Configuración de alta precisión para el seguimiento de ubicación
    final LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Solo actualizar si se mueve más de 10 metros
    );
    
    // Suscripción al stream de posición
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
          debugPrint('Posición actualizada: ${position.latitude}, ${position.longitude}');
        });
        _updateCurrentLocationMarker();
        _calculateDistancesToOffices();
      },
      onError: (e) {
        debugPrint('Error en el stream de posición: $e');
      },
    );
  }

  Future<void> _loadOffices() async {
    try {
      // Obtenemos las oficinas directamente del datasource
      final offices = await _officeDataSource.getOffices();
      setState(() {
        _offices = offices;
      });
      
      // Si ya tenemos la posición actual, calculamos las distancias
      if (_currentPosition != null) {
        _calculateDistancesToOffices();
      }
      
      // Actualizamos los marcadores de las oficinas
      _updateOfficeMarkers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load offices: $e';
      });
    }
  }

  // Función para calcular distancias de la ubicación actual a las oficinas
  void _calculateDistancesToOffices() {
    if (_currentPosition == null || _offices.isEmpty) return;
    
    final List<Map<String, dynamic>> updatedOffices = [];
    
    for (var office in _offices) {
      final double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        office['latitude'] as double,
        office['longitude'] as double,
      );
      
      // Convertir a millas (1 metro = 0.000621371 millas)
      final double distanceInMiles = distanceInMeters * 0.000621371;
      
      updatedOffices.add({
        ...office,
        'distanceInMiles': distanceInMiles,
      });
    }
    
    // Ordenar por distancia (más cercana primero)
    updatedOffices.sort((a, b) => 
      (a['distanceInMiles'] as double).compareTo(b['distanceInMiles'] as double),
    );
    
    setState(() {
      _offices = updatedOffices;
    });
  }

  void _updateMapPosition() {
    if (_currentPosition != null && _mapController != null) {
      final cameraPosition = CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14.0,
      );
      _mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      
      _updateCurrentLocationMarker();
    }
  }

  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;
    
    // Eliminar el marcador anterior de ubicación actual
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
      
      // Agregar el nuevo marcador con la posición actualizada
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: InfoWindow(
            title: 'Mi ubicación actual',
            snippet: _isEmulatorOrSimulator ? 'Ubicación simulada' : null,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          zIndex: 2, // Para asegurar que está encima de otros marcadores
        ),
      );
    });
  }

  void _updateOfficeMarkers() {
    if (_mapController == null) return;
    
    // Evitamos actualizar los marcadores de oficina más de una vez
    if (_markersUpdated) return;
    
    setState(() {
      // Eliminamos cualquier marcador de oficina existente
      _markers.removeWhere((marker) => 
        marker.markerId.value.startsWith('office_'),
      );
      
      // Agregamos los marcadores para cada oficina
      for (var i = 0; i < _offices.length; i++) {
        final office = _offices[i];
        final marker = Marker(
          markerId: MarkerId('office_$i'),
          position: LatLng(
            office['latitude'] as double,
            office['longitude'] as double,
          ),
          infoWindow: InfoWindow(
            title: office['name'] as String,
            snippet: office['address'] as String,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndex: 1,
        );
        _markers.add(marker);
      }
      
      _markersUpdated = true;
    });
  }

  // Función para expandir o contraer la hoja
  void _toggleBottomSheet() {
    if (_scrollController.size <= 0.25) {
      // Si está minimizado, expandirlo a tamaño medio
      _scrollController.animateTo(
        0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Si está expandido, minimizarlo
      _scrollController.animateTo(
        0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Método para simular una ubicación personalizada (útil en emuladores)
  void _setCustomLocation() {
    if (!mounted) return;

    // Para San Diego, California
    final double sandiegoLat = 32.715738;
    final double sandiegoLng = -117.161084;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Establecer ubicación personalizada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona una ubicación cercana a las oficinas:'),
            const SizedBox(height: 16),
            // Opción de San Diego
            ListTile(
              title: const Text('San Diego (cerca de las oficinas)'),
              onTap: () {
                setState(() {
                  // Simular ubicación en San Diego
                  if (_currentPosition != null) {
                    _currentPosition = Position(
                      latitude: sandiegoLat,
                      longitude: sandiegoLng,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    );
                    _updateMapPosition();
                    _calculateDistancesToOffices();
                  }
                });
                Navigator.of(context).pop();
              },
            ),
            // Opción para usar ubicación actual del emulador
            ListTile(
              title: const Text('Usar ubicación del emulador'),
              onTap: () {
                _loadLocationData(); // Recargar ubicación actual
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Locations'),
        elevation: 0,
        actions: [
          // Mostrar un botón para cambiar la ubicación si es un emulador
          if (_isEmulatorOrSimulator)
            IconButton(
              icon: const Icon(Icons.location_searching),
              tooltip: 'Cambiar ubicación simulada',
              onPressed: _setCustomLocation,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                    _markersUpdated = false;
                  });
                  _loadLocationData();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // El mapa ocupa toda la pantalla
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition != null
                ? LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  )
                : const LatLng(0, 0),
            zoom: 14.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // Usaremos nuestro propio botón
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _updateMapPosition();
            _updateOfficeMarkers();
          },
        ),

        // Botones flotantes para controlar el mapa
        Positioned(
          right: 16,
          bottom: 180, // Posicionado encima del DraggableScrollableSheet
          child: Column(
            children: [
              // Botón para ir a la ubicación actual
              FloatingActionButton(
                heroTag: 'currentLocation',
                backgroundColor: Colors.white,
                onPressed: () {
                  _updateMapPosition();
                },
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              // Botón para expandir/contraer la lista de oficinas
              FloatingActionButton(
                heroTag: 'toggleList',
                backgroundColor: Colors.white,
                onPressed: _toggleBottomSheet,
                child: const Icon(Icons.list, color: Colors.blue),
              ),
            ],
          ),
        ),

        // Si estamos en un emulador, mostramos un banner
        if (_isEmulatorOrSimulator)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.yellow.withAlpha(200),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ubicación simulada - Toca el ícono de búsqueda para cambiar',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _isEmulatorOrSimulator = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

        // Lista de oficinas en un DraggableScrollableSheet
        DraggableScrollableSheet(
          initialChildSize: 0.25, // Tamaño inicial (25% de la pantalla)
          minChildSize: 0.1, // Tamaño mínimo (10% de la pantalla)
          maxChildSize: 0.6, // Tamaño máximo (60% de la pantalla)
          controller: _scrollController,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51), // Cambiado de withOpacity(0.2) a withAlpha(51)
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 12),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  // Título
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Oficinas cercanas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Lista de oficinas
                  Expanded(
                    child: _offices.isEmpty
                        ? const Center(child: Text('No hay oficinas disponibles'))
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _offices.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final office = _offices[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(office['name'] as String),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(office['address'] as String),
                                    if (office['phone'] != null)
                                      Text('Tel: ${office['phone']}', 
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text('${office['distanceInMiles'].toStringAsFixed(2)} miles'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.directions),
                                  onPressed: () {
                                    // Centrar el mapa en esta oficina
                                    if (_mapController != null) {
                                      final cameraPosition = CameraPosition(
                                        target: LatLng(
                                          office['latitude'] as double,
                                          office['longitude'] as double,
                                        ),
                                        zoom: 16.0,
                                      );
                                      _mapController!.animateCamera(
                                        CameraUpdate.newCameraPosition(cameraPosition),
                                      );
                                      
                                      // Minimizar el panel para ver mejor el mapa
                                      _scrollController.animateTo(
                                        0.1,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                                onTap: () {
                                  // Centrar el mapa en esta oficina al tocar la fila
                                  if (_mapController != null) {
                                    final cameraPosition = CameraPosition(
                                      target: LatLng(
                                        office['latitude'] as double,
                                        office['longitude'] as double,
                                      ),
                                      zoom: 16.0,
                                    );
                                    _mapController!.animateCamera(
                                      CameraUpdate.newCameraPosition(cameraPosition),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
