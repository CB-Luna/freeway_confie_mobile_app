import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/map_style_manager.dart';

class MapStyleController extends ChangeNotifier {
  late MapStyleManager _styleManager;
  GoogleMapController? _mapController;
  String? _customStyle;
  MapType _mapType = MapType.normal;
  bool _isLoadingStyle = false;

  MapType get currentMapType => _mapType;
  String? get currentCustomStyle => _customStyle;
  bool get isLoadingStyle => _isLoadingStyle;

  MapStyleController() {
    _styleManager = MapStyleManager(
      onStyleLoadStarted: _handleStyleLoadStarted,
      onStyleLoadComplete: _handleStyleLoadComplete,
      onMapTypeChanged: _handleMapTypeChanged,
    );
  }

  void _handleStyleLoadStarted() {
    _isLoadingStyle = true;
    notifyListeners();
  }

  void _handleStyleLoadComplete(bool success) {
    _isLoadingStyle = false;
    if (!success) {
      debugPrint('❌ Error al cargar el estilo del mapa');
    }
    notifyListeners();
  }

  void _handleMapTypeChanged(MapType newType) {
    _mapType = newType;
    notifyListeners();
  }

  void initMapController(GoogleMapController controller) {
    _mapController = controller;
    _loadInitialStyle();
  }

  Future<void> _loadInitialStyle() async {
    if (_mapController == null) return;
    await _styleManager.loadMapStyle(_mapController!);
  }

  Future<void> changeMapStyle() async {
    if (_mapController == null) return;
    await _styleManager.changeMapType(_mapController!);
    _customStyle = _styleManager.currentCustomStyle;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}
