import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/platform/device_info.dart';
import '../../../data/models/office/office.dart';
import '../../../data/services/office_service.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_offices.dart';

class LocationState {
  final bool isLoading;
  final Position? currentPosition;
  final List<Office> offices; // Todas las oficinas
  final List<Office> nearbyOffices; // Oficinas dentro del radio de cobertura
  final String? errorMessage;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final bool hasLocationPermission;
  final bool hasSearchedByZipCode;
  final double searchRadiusInMiles; // Radio de búsqueda en millas
  final bool showAllOffices; // Indica si se deben mostrar todas las oficinas
  final int? selectedOfficeId; // ID de la oficina seleccionada

  LocationState({
    this.isLoading = true,
    this.currentPosition,
    this.offices = const [],
    this.nearbyOffices = const [],
    this.errorMessage,
    this.markers = const {},
    this.circles = const {},
    this.hasLocationPermission = true,
    this.hasSearchedByZipCode = false,
    this.searchRadiusInMiles = 1.0, // Por defecto, 1 milla
    this.showAllOffices = false,
    this.selectedOfficeId,
  });

  LocationState copyWith({
    bool? isLoading,
    Position? currentPosition,
    List<Office>? offices,
    List<Office>? nearbyOffices,
    String? errorMessage,
    Set<Marker>? markers,
    Set<Circle>? circles,
    bool? hasLocationPermission,
    bool? hasSearchedByZipCode,
    double? searchRadiusInMiles,
    bool? showAllOffices,
    int? selectedOfficeId,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      offices: offices ?? this.offices,
      nearbyOffices: nearbyOffices ?? this.nearbyOffices,
      errorMessage: errorMessage ?? this.errorMessage,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      hasSearchedByZipCode: hasSearchedByZipCode ?? this.hasSearchedByZipCode,
      searchRadiusInMiles: searchRadiusInMiles ?? this.searchRadiusInMiles,
      showAllOffices: showAllOffices ?? this.showAllOffices,
      selectedOfficeId: selectedOfficeId ?? this.selectedOfficeId,
    );
  }
}

class LocationController extends ChangeNotifier {
  final GetCurrentLocation getCurrentLocation;
  final GetOffices getOffices;
  final DeviceInfo deviceInfo;

  MapController? mapController;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Variables para el manejo dinámico de la carga de oficinas según la posición de la cámara
  LatLng? _initialCameraPosition; // Posición inicial de la cámara
  LatLng?
      _lastCameraPosition; // Última posición de la cámara donde se cargaron oficinas
  double _maxDistanceToOffice =
      0.0; // Distancia máxima a la oficina más lejana (en millas)
  bool _isLoadingOffices =
      false; // Bandera para evitar múltiples cargas simultáneas

  LocationState _state = LocationState();
  LocationState get state => _state;

  // Coordenadas por defecto para simuladores (San Diego) Sin covertura
  // static const double defaultLat = 32.715738;
  // static const double defaultLng = -117.161084;
  // Coordenadas por defecto para emuladores (San Diego) Con covertura
  static const double defaultLat = 32.6708864;
  static const double defaultLng = -117.1033635;

  LocationController({
    required this.getCurrentLocation,
    required this.getOffices,
    required this.deviceInfo,
  });

  Future<void> initialize() async {
    try {
      // Inicializar el estado
      _updateState(
        isLoading: true,
        errorMessage: null,
        selectedOfficeId: null,
      );

      // Verificar y solicitar permisos de ubicación
      await _checkAndRequestLocationPermission();

      // Si no tiene permisos, usar ubicación por defecto sin solicitar permisos
      if (!_state.hasLocationPermission) {
        await _useDefaultLocation();
      } else {
        await _loadCurrentLocation();
      }

      await _loadOffices();
    } catch (e) {
      _updateState(
        isLoading: false,
        errorMessage: 'Error initializing: ${e.toString()}',
      );
    }
  }

  Future<void> retry() async {
    _updateState(
      isLoading: true,
      errorMessage: null,
    );
    await initialize();
  }

  void _updateState({
    bool? isLoading,
    Position? currentPosition,
    List<Office>? offices,
    List<Office>? nearbyOffices,
    String? errorMessage,
    Set<Marker>? markers,
    Set<Circle>? circles,
    bool? hasLocationPermission,
    bool? hasSearchedByZipCode,
    double? searchRadiusInMiles,
    bool? showAllOffices,
    int? selectedOfficeId,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      currentPosition: currentPosition,
      offices: offices,
      nearbyOffices: nearbyOffices,
      errorMessage: errorMessage,
      markers: markers,
      circles: circles,
      hasLocationPermission: hasLocationPermission,
      hasSearchedByZipCode: hasSearchedByZipCode,
      searchRadiusInMiles: searchRadiusInMiles,
      showAllOffices: showAllOffices,
      selectedOfficeId: selectedOfficeId,
    );
    notifyListeners();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateState(hasLocationPermission: false);
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateState(hasLocationPermission: false);
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateState(hasLocationPermission: false);
      throw Exception('Location permissions are permanently denied');
    }

    // Si llegamos aquí, tenemos permisos
    _updateState(hasLocationPermission: true);
  }

  /// Solicita permisos de ubicación y actualiza el estado
  Future<void> requestLocationPermission() async {
    try {
      _updateState(isLoading: true, errorMessage: null);

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(
          isLoading: false,
          hasLocationPermission: false,
          errorMessage: 'Location services are disabled',
        );
        return;
      }

      final LocationPermission permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _updateState(
          isLoading: false,
          hasLocationPermission: false,
          errorMessage: 'Location permissions are denied',
        );
        return;
      }

      // Si llegamos aquí, tenemos permisos
      _updateState(hasLocationPermission: true);

      // Reiniciar la inicialización
      await initialize();
    } catch (e) {
      _updateState(
        isLoading: false,
        hasLocationPermission: false,
        errorMessage: 'Error requesting location permission: ${e.toString()}',
      );
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await getCurrentLocation.execute();
      _updateState(
        currentPosition: position,
        isLoading: false,
      );
      _startLocationTracking();
    } catch (e) {
      _updateState(
        isLoading: false,
        errorMessage: 'Could not determine your location: ${e.toString()}',
      );
    }
  }

  // Método para usar ubicación por defecto en caso de no tener permisos
  Future<void> _useDefaultLocation() async {
    debugPrint('Usando ubicación por defecto cuando no hay permisos');
    final newPosition = Position(
      latitude: defaultLat,
      longitude: defaultLng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    _updateState(
      currentPosition: newPosition,
      isLoading: false,
    );
  }

  void _startLocationTracking() {
    _positionStreamSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateState(currentPosition: position);
        _updateCurrentLocationMarker();
        _calculateDistancesToOffices();
      },
      onError: (e) {
        debugPrint('Error in position stream: $e');
      },
    );
  }

  Future<void> _loadOffices() async {
    try {
      final offices =
          await getOffices.execute(currentPosition: state.currentPosition);
      _updateState(offices: offices);

      if (state.currentPosition != null) {
        _calculateDistancesToOffices();
      }

      _updateOfficeMarkers();
    } catch (e) {
      _updateState(
        errorMessage: 'Could not load offices: ${e.toString()}',
      );
    }
  }

  void _calculateDistancesToOffices() {
    if (state.currentPosition == null) return;

    if (state.offices.isNotEmpty) {
      final List<Office> updatedOffices = [];
      final List<Office> nearbyOffices = [];

      for (var office in state.offices) {
        updatedOffices.add(office);

        // Filtrar oficinas dentro del radio de búsqueda
        if (office.distanceObj.value <= state.searchRadiusInMiles) {
          nearbyOffices.add(office);
        }
      }

      // Ordenar por distancia
      updatedOffices.sort(
        (a, b) => a.distanceObj.value.compareTo(b.distanceObj.value),
      );

      nearbyOffices.sort(
        (a, b) => a.distanceObj.value.compareTo(b.distanceObj.value),
      );

      // Si hay una oficina seleccionada, no actualizar las oficinas cercanas
      if (state.selectedOfficeId != null) {
        // Encontrar la oficina seleccionada
        final selectedOffice = updatedOffices.firstWhere(
          (office) => office.locationId == state.selectedOfficeId,
          orElse: () => updatedOffices.first,
        );

        _updateState(
          offices: updatedOffices,
          nearbyOffices: [selectedOffice],
          // Si estamos mostrando todas las oficinas, mantener ese estado
          showAllOffices: state.showAllOffices,
        );
      } else {
        _updateState(
          offices: updatedOffices,
          nearbyOffices: nearbyOffices,
          // Si estamos mostrando todas las oficinas, mantener ese estado
          showAllOffices: state.showAllOffices,
        );
      }
    }

    // Actualizar el círculo de cobertura para reflejar el radio de búsqueda
    _updateCoverageCircle();
  }

  // Método para crear un ícono personalizado para el marcador de ubicación actual
  Widget _createCustomMarkerIcon() {
    return Image.asset(
      'assets/location/location_marker.png',
      width: 30,
      height: 30,
    );
  }

  // Método para actualizar el círculo de cobertura
  void _updateCoverageCircle() {
    if (state.currentPosition == null) {
      debugPrint(
        'ERROR: No se puede actualizar círculo - currentPosition es null',
      );
      return;
    }

    debugPrint('\n==== ACTUALIZANDO CÍRCULO DE COBERTURA ====');
    debugPrint('Radio actual en estado: ${state.searchRadiusInMiles} millas');

    final circles = <Circle>{};

    // Convertir millas a metros para el radio del círculo (1 milla = 1609.34 metros)
    final radiusInMeters = state.searchRadiusInMiles * 1609.34;

    debugPrint(
      'Creando círculo con radio: ${state.searchRadiusInMiles} millas ($radiusInMeters metros)',
    );
    debugPrint(
      'Posición del círculo: ${state.currentPosition!.latitude}, ${state.currentPosition!.longitude}',
    );

    circles.add(
      Circle(
        LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        radiusInMeters, // Radio en metros para la visualización
      ),
    );

    debugPrint(
      'Actualizando estado con nuevo círculo (radio: ${state.searchRadiusInMiles} millas)',
    );
    _updateState(circles: circles);
    debugPrint(
      'Estado actualizado - Número de círculos: ${state.circles.length}',
    );

    // Forzar notificación a los listeners
    debugPrint('Notificando a los listeners para actualizar UI');
    notifyListeners();
  }

  void _updateCurrentLocationMarker() async {
    if (state.currentPosition == null) return;

    final currentMarkers = Set<Marker>.from(state.markers);
    currentMarkers.removeWhere(
      (marker) =>
          marker.point.latitude == state.currentPosition!.latitude &&
          marker.point.longitude == state.currentPosition!.longitude,
    );

    // Obtener el ícono personalizado
    final customIcon = _createCustomMarkerIcon();

    currentMarkers.add(
      Marker(
        point: LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        child: customIcon,
      ),
    );

    _updateState(markers: currentMarkers);

    // Actualizar el círculo de cobertura
    _updateCoverageCircle();
  }

  void _updateOfficeMarkers() {
    if (state.offices.isEmpty) return;

    // Limpiar TODOS los marcadores existentes excepto el de posición actual
    // Esto asegura que no queden marcadores seleccionados de operaciones anteriores
    final currentMarkers = <Marker>{};

    // Mantener solo el marcador de la posición actual si existe
    if (state.currentPosition != null) {
      // Buscar el marcador de posición actual si existe
      for (var marker in state.markers) {
        if (marker.point.latitude == state.currentPosition!.latitude &&
            marker.point.longitude == state.currentPosition!.longitude) {
          currentMarkers.add(marker);
          break;
        }
      }
    }

    // Registrar el estado para depuración
    debugPrint('\n==== ACTUALIZANDO MARCADORES DE OFICINAS ====');
    debugPrint('Oficina seleccionada ID: ${state.selectedOfficeId}');
    debugPrint('Número total de oficinas: ${state.offices.length}');

    // Variable para almacenar la oficina seleccionada
    Office? selectedOffice;

    for (var i = 0; i < state.offices.length; i++) {
      final office = state.offices[i];
      final isSelected = state.selectedOfficeId == office.locationId;

      // Si esta oficina está seleccionada, guardarla para actualizar el estado después
      if (isSelected) {
        selectedOffice = office;
      }

      // Tamaño del marcador: mucho más grande si está seleccionado
      final markerSize = isSelected ? 120.0 : 80.0;

      final marker = Marker(
        point: LatLng(office.latitude, office.longitude),
        child: GestureDetector(
          onTap: () {
            // Al hacer tap en un marcador, seleccionarlo y actualizar la vista
            debugPrint('Tap en marcador de oficina: ${office.name}');
            goToOffice(office);
          },
          child: Container(
            decoration: isSelected
                ? const BoxDecoration(
                    // Agregar un resplandor alrededor del marcador seleccionado
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme
                            .primaryColor, // Resplandor blanco más intenso
                        spreadRadius: 15,
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      ),
                    ],
                  )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Imagen base del marcador
                Image.asset(
                  'assets/location/freeway_marker.png',
                  width: isSelected
                      ? markerSize.toDouble() * 2
                      : markerSize.toDouble(),
                  height: isSelected
                      ? markerSize.toDouble() * 2
                      : markerSize.toDouble(),
                  scale: isSelected ? 2.0 : 1.0,
                ),
              ],
            ),
          ),
        ),
      );

      currentMarkers.add(marker);
    }

    // Actualizar el estado con la oficina seleccionada fuera del bucle
    if (selectedOffice != null && state.selectedOfficeId != null) {
      // Solo actualizar las nearbyOffices si no estamos mostrando todas las oficinas
      if (!state.showAllOffices) {
        _updateState(
          markers: currentMarkers,
          nearbyOffices: [selectedOffice],
          showAllOffices: false,
        );
      } else {
        // Si estamos mostrando todas las oficinas, solo actualizar los marcadores
        _updateState(markers: currentMarkers);
      }
    } else {
      _updateState(markers: currentMarkers);
    }
  }

  void updateMapPosition() {
    if (state.currentPosition != null && mapController != null) {
      // En flutter_map, movemos la cámara directamente a una posición y zoom
      mapController!.move(
        LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
        14.0, // nivel de zoom
      );

      // Actualizar la posición inicial y última posición de la cámara
      _initialCameraPosition = LatLng(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
      );
      _lastCameraPosition = _initialCameraPosition;
    }
  }

  void onMapCreated(MapController controller) {
    mapController = controller;

    // Guardar la posición inicial de la cámara cuando se crea el mapa
    if (state.currentPosition != null) {
      _initialCameraPosition = LatLng(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
      );
      _lastCameraPosition = _initialCameraPosition;
    }
  }

  // Método para manejar el movimiento de la cámara
  void onCameraMove(LatLng position) {
    // Si no tenemos posición inicial o última posición, establecerlas
    if (_initialCameraPosition == null) {
      _initialCameraPosition = position;
      _lastCameraPosition = position;
      return;
    }

    // Si estamos cargando oficinas, no hacer nada
    if (_isLoadingOffices) return;

    // Calcular la distancia entre la posición actual de la cámara y la última posición donde cargamos oficinas
    final distanceInMeters = Geolocator.distanceBetween(
      _lastCameraPosition!.latitude,
      _lastCameraPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    // Convertir la distancia a millas (1 milla = 1609.34 metros)
    final distanceInMiles = distanceInMeters / 1609.34;

    // Si la distancia es mayor que la distancia máxima a la oficina más lejana,
    // o si estamos mostrando todas las oficinas y nos hemos movido significativamente,
    // cargar nuevas oficinas
    final significantDistance =
        state.showAllOffices ? 5.0 : _maxDistanceToOffice;
    if (distanceInMiles > significantDistance * 0.7) {
      // 70% de la distancia máxima como umbral
      _loadOfficesAtPosition(position);
    }
  }

  // Método para cargar oficinas en una posición específica
  Future<void> _loadOfficesAtPosition(LatLng position) async {
    // Evitar múltiples cargas simultáneas
    if (_isLoadingOffices) return;

    _isLoadingOffices = true;

    try {
      // No mostrar indicador de carga para no interrumpir la experiencia del usuario
      // pero sí actualizar el estado interno

      // Crear una posición temporal para pasar al caso de uso
      final tempPosition = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // Obtener oficinas cercanas a la posición actual de la cámara
      final result = await getOffices.execute(currentPosition: tempPosition);

      if (result.isNotEmpty) {
        // Actualizar la última posición donde cargamos oficinas
        _lastCameraPosition = position;

        // Combinar las nuevas oficinas con las existentes, evitando duplicados
        final existingOfficeIds =
            state.offices.map((o) => o.locationId).toSet();
        final newOffices = [
          ...state.offices,
          ...result.where(
            (office) => !existingOfficeIds.contains(office.locationId),
          ),
        ];

        // Actualizar la lista de oficinas
        _updateState(offices: newOffices);

        // Recalcular las distancias y actualizar los marcadores
        _calculateDistancesToOffices();
        _updateOfficeMarkers();

        // Actualizar la distancia máxima a la oficina más lejana
        if (state.nearbyOffices.isNotEmpty) {
          _maxDistanceToOffice = state.nearbyOffices.last.distanceObj.value;
        }
      }
    } catch (e) {
      // No mostrar error al usuario para no interrumpir la experiencia
      debugPrint('Error al cargar oficinas en la posición: $e');
    } finally {
      _isLoadingOffices = false;
    }
  }

  // Callback para expandir el DraggableScrollableSheet
  VoidCallback? onMarkerTap;

  void goToOffice(Office office) {
    // Actualizar el ID de la oficina seleccionada
    _updateState(
      selectedOfficeId: office.locationId,
      showAllOffices:
          false, // Asegurarnos de que no estamos mostrando todas las oficinas
    );

    // Actualizar los marcadores para reflejar la selección
    _updateOfficeMarkers();

    // Notificar a la vista que debe expandir el DraggableScrollableSheet
    if (onMarkerTap != null) {
      onMarkerTap!();
    }
  }

  // Nuevo método para navegar a la oficina y ajustar la cámara
  // Este método se usará cuando se seleccione una oficina desde la lista
  void navigateToOffice(Office office) {
    // Primero seleccionamos la oficina (actualiza marcadores)
    goToOffice(office);

    // Luego ajustamos la cámara para centrar la oficina
    if (mapController != null) {
      // En flutter_map, movemos la cámara directamente a una posición y zoom
      mapController!.move(
        LatLng(office.latitude, office.longitude),
        16.0, // nivel de zoom
      );
    }
  }

  /// Busca oficinas cercanas a un código postal
  Future<void> searchByZipCode(String zipCode, BuildContext context) async {
    try {
      _updateState(isLoading: true, errorMessage: null, selectedOfficeId: null);

      // Crear una instancia del servicio de oficinas
      final officeService = OfficeService();

      // Obtener las oficinas cercanas al código postal
      final List<Office> nearbyOffices =
          await officeService.getNearbyOfficesByZipCode(zipCode);

      if (nearbyOffices.isEmpty) {
        _updateState(
          isLoading: false,
          hasSearchedByZipCode: false,
          errorMessage:
              'No se encontraron oficinas cercanas al código postal: $zipCode',
        );
        return;
      }

      // Usar la ubicación de la primera oficina como ubicación actual
      final firstOffice = nearbyOffices.first;
      final newPosition = Position(
        latitude: firstOffice.latitude,
        longitude: firstOffice.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      _updateState(
        currentPosition: newPosition,
        isLoading: false,
        offices: nearbyOffices,
        nearbyOffices: nearbyOffices,
        hasSearchedByZipCode: true,
      );

      // Mover la cámara directamente a la ubicación de la primera oficina encontrada
      if (mapController != null) {
        mapController!.move(
          LatLng(firstOffice.latitude, firstOffice.longitude),
          14.0, // nivel de zoom
        );

        // Actualizar la posición inicial y última posición de la cámara
        _initialCameraPosition =
            LatLng(firstOffice.latitude, firstOffice.longitude);
        _lastCameraPosition = _initialCameraPosition;
      }

      // Actualizar marcadores de oficinas
      _updateOfficeMarkers();
    } catch (e) {
      if (!context.mounted) return;
      _updateState(
        isLoading: false,
        errorMessage: context.translateWithArgs(
          'zipCode.errorSearchingByZipCode',
          args: [e.toString()],
        ),
      );
    }
  }

  // Método para expandir el radio de búsqueda
  Future<void> expandSearchRadius(
    BuildContext context,
    double maxDistanceAllowed,
  ) async {
    // Incrementar el radio de búsqueda en 1 milla cada vez
    final newRadius = state.searchRadiusInMiles + 1.0;
    final maxDistanceAllowedInMeters = maxDistanceAllowed / 1609.34;

    // Verificar si el nuevo radio excede el límite máximo de 10 millas
    if (newRadius > maxDistanceAllowedInMeters) {
      // Mostrar un mensaje al usuario indicando que se ha alcanzado el límite
      showAppSnackBar(
        context,
        context.translate('office.maxRadius'),
        const Duration(seconds: 2),
        backgroundColor: AppTheme.getOrangeColor(context),
      );
      return; // Salir del método sin expandir más el radio
    }

    // Restablecer la oficina seleccionada
    debugPrint('Actualizando estado con nuevo radio: $newRadius millas');
    _updateState(
      searchRadiusInMiles: newRadius,
      selectedOfficeId: null,
    );
    debugPrint(
      'Estado actualizado - Radio actual: ${state.searchRadiusInMiles} millas',
    );

    // Actualizar el círculo de cobertura con el nuevo radio
    debugPrint(
      'Llamando a _updateCoverageCircle() para actualizar círculo visual',
    );
    _updateCoverageCircle();

    // Recalcular las oficinas cercanas con el nuevo radio
    debugPrint('Recalculando oficinas cercanas con nuevo radio');
    _calculateDistancesToOffices();

    // Actualizar el zoom del mapa para mostrar el nuevo radio
    _updateCameraZoomForRadius(newRadius);

    // Mostrar un mensaje al usuario
    showAppSnackBar(
      context,
      context.translateWithArgs(
        'office.searchRadius',
        args: ['${newRadius.toInt()}'],
      ),
      const Duration(seconds: 2),
      backgroundColor: AppTheme.getOrangeColor(context),
    );
  }

  // Método para actualizar el zoom de la cámara según el radio
  void _updateCameraZoomForRadius(double radiusInMiles) {
    debugPrint('\n==== ACTUALIZANDO ZOOM DE CÁMARA PARA RADIO ====');
    debugPrint('Radio en millas: $radiusInMiles');

    if (state.currentPosition == null) {
      debugPrint(
        'ERROR: No se puede actualizar zoom - currentPosition es null',
      );
      return;
    }

    if (mapController == null) {
      debugPrint('ERROR: No se puede actualizar zoom - mapController es null');
      return;
    }

    // Calcular el zoom apropiado basado en el radio
    // Fórmula aproximada: zoom = 14.0 - log2(radiusInMiles)
    // Esto hace que el zoom disminuya a medida que aumenta el radio
    double zoom = 14.0 - (radiusInMiles / 2.0);
    // Asegurar que el zoom no sea demasiado pequeño
    zoom = zoom.clamp(10.0, 15.0);
    debugPrint('Nuevo zoom calculado: $zoom');

    debugPrint(
      'Moviendo cámara a posición: ${state.currentPosition!.latitude}, ${state.currentPosition!.longitude} con zoom: $zoom',
    );
    // En flutter_map, movemos la cámara directamente a una posición y zoom
    mapController!.move(
      LatLng(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
      ),
      zoom,
    );
    debugPrint('Cámara movida correctamente');

    // Forzar una actualización del círculo de cobertura
    debugPrint(
      'Forzando actualización del círculo de cobertura desde _updateCameraZoomForRadius',
    );
    _updateCoverageCircle();
  }

  // Método para mostrar todas las oficinas
  void showAllOffices() {
    // Obtener todas las oficinas disponibles
    final allOffices = state.offices;

    // Restablecer la oficina seleccionada y actualizar las oficinas cercanas
    _updateState(
      showAllOffices: true,
      selectedOfficeId: null,
      nearbyOffices: allOffices, // Mostrar todas las oficinas en la lista
    );

    // Actualizar los marcadores
    _updateOfficeMarkers();

    // Ajustar el zoom para mostrar todas las oficinas
    if (mapController != null && allOffices.isNotEmpty) {
      final bounds = _getBoundsForOffices(allOffices);

      // En flutter_map, necesitamos calcular el centro y el zoom manualmente
      // ya que MapController no tiene método fitBounds
      final center = LatLng(
        (bounds.northEast.latitude + bounds.southWest.latitude) / 2,
        (bounds.northEast.longitude + bounds.southWest.longitude) / 2,
      );

      // Calcular un zoom aproximado basado en los límites
      // Esto es una aproximación simple
      final latDiff =
          (bounds.northEast.latitude - bounds.southWest.latitude).abs();
      final lngDiff =
          (bounds.northEast.longitude - bounds.southWest.longitude).abs();
      final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

      // Fórmula aproximada para calcular el zoom
      final zoom =
          14.0 - (maxDiff * 30); // Ajustar este factor según sea necesario

      // Mover la cámara al centro calculado con el zoom apropiado
      mapController!.move(center, zoom.clamp(10.0, 15.0));
    }
  }

  // Método auxiliar para obtener los límites que contienen todas las oficinas
  LatLngBounds _getBoundsForOffices(List<Office> offices) {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final office in offices) {
      if (office.latitude < minLat) minLat = office.latitude;
      if (office.latitude > maxLat) maxLat = office.latitude;
      if (office.longitude < minLng) minLng = office.longitude;
      if (office.longitude > maxLng) maxLng = office.longitude;
    }

    // Añadir un poco de margen
    minLat -= 0.1;
    maxLat += 0.1;
    minLng -= 0.1;
    maxLng += 0.1;

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  // Método para obtener la lista de oficinas a mostrar
  List<Office> getOfficeListToDisplay() {
    // Si showAllOffices es true o no hay oficinas cercanas, mostrar todas las oficinas
    if (state.showAllOffices || state.nearbyOffices.isEmpty) {
      return state.offices;
    }
    // De lo contrario, mostrar solo las oficinas cercanas
    return state.nearbyOffices;
  }

  // Método para verificar si hay oficinas cercanas
  bool hasNearbyOffices() {
    return state.nearbyOffices.isNotEmpty;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
