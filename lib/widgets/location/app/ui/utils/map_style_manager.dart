import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapStyleManager {
  final VoidCallback onStyleLoadStarted;
  final ValueChanged<bool> onStyleLoadComplete;
  final ValueChanged<MapType> onMapTypeChanged;
  MapType _currentMapType = MapType.normal;
  String? _currentStyle;
  bool _isLoadingStyle = false;

  MapStyleManager({
    required this.onStyleLoadStarted,
    required this.onStyleLoadComplete,
    required this.onMapTypeChanged,
  });

  MapType get currentMapType => _currentMapType;
  String? get currentCustomStyle => _currentStyle;
  bool get isLoadingStyle => _isLoadingStyle;

  Future<void> loadMapStyle(GoogleMapController controller) async {
    if (_isLoadingStyle) return;

    try {
      _isLoadingStyle = true;
      onStyleLoadStarted();
      onStyleLoadComplete(true);
      debugPrint('✅ Map style loaded');
    } catch (e) {
      debugPrint('❌ Error loading map style: $e');
      onStyleLoadComplete(false);
    } finally {
      _isLoadingStyle = false;
    }
  }

  Future<void> changeMapType(GoogleMapController controller) async {
    final previousType = _currentMapType;

    try {
      switch (_currentMapType) {
        case MapType.normal:
          _currentMapType = MapType.satellite;
          _currentStyle = null;
          break;
        case MapType.satellite:
          _currentMapType = MapType.hybrid;
          _currentStyle = null;
          break;
        case MapType.hybrid:
          _currentMapType = MapType.normal;
          _currentStyle = await _loadCustomMapStyle();
          break;
        default:
          _currentMapType = MapType.normal;
          _currentStyle = null;
      }

      onMapTypeChanged(_currentMapType);
      await loadMapStyle(controller);
    } catch (e) {
      debugPrint('❌ Error changing map type: $e');
      _currentMapType = previousType;
      onMapTypeChanged(_currentMapType);
    }
  }

  Future<String?> _loadCustomMapStyle() async {
    try {
      return await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      debugPrint('❌ Error loading custom map style: $e');
      return null;
    }
  }
}
