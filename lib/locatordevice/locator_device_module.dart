import 'package:flutter/material.dart';

import '../core/platform/device_info.dart';
import 'di/injection_container.dart' as di;
import 'domain/usecases/get_current_location.dart';
import 'domain/usecases/get_offices.dart';
import 'presentation/pages/location_details_view.dart';

/// Main entry point for the Locator Device module
class LocatorDeviceModule {
  static bool _initialized = false;

  /// Navigates to the Location Details view
  ///
  /// This method should be called from the menu when the location option is selected
  static Future<void> navigateToLocationView(BuildContext context) async {
    try {
      // Add debugging info
      debugPrint('LocatorDeviceModule: Starting navigation to location view');
      
      // Store the current context navigator before async operations
      final navigator = Navigator.of(context);

      // Initialize dependencies if not already done
      if (!_initialized) {
        debugPrint('LocatorDeviceModule: Initializing dependencies');
        try {
          await di.init();
          _initialized = true;
          debugPrint('LocatorDeviceModule: Dependencies initialized successfully');
        } catch (e) {
          debugPrint('LocatorDeviceModule: Error initializing dependencies: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error initializing location services: $e')),
            );
          }
          return;
        }
      }

      // Check if the context is still valid before navigating
      if (!context.mounted) {
        debugPrint('LocatorDeviceModule: Context no longer mounted');
        return;
      }

      // Verify dependencies are available
      try {
        final getCurrentLocation = di.sl.get<GetCurrentLocation>();
        final getOffices = di.sl.get<GetOffices>();
        final deviceInfo = di.sl.get<DeviceInfo>();
        debugPrint('LocatorDeviceModule: Dependencies retrieved successfully');
        
        // Navigate to the location view with required dependencies
        debugPrint('LocatorDeviceModule: Navigating to LocationDetailsView');
        await navigator.push(
          MaterialPageRoute(
            settings: RouteSettings(
              arguments: {
                'getCurrentLocation': getCurrentLocation,
                'getOffices': getOffices,
                'deviceInfo': deviceInfo,
              },
            ),
            builder: (context) => const LocationDetailsView(),
          ),
        );
        debugPrint('LocatorDeviceModule: Navigation completed');
      } catch (e) {
        debugPrint('LocatorDeviceModule: Error retrieving dependencies: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accessing location services: $e')),
          );
        }
      }
    } catch (e) {
      debugPrint('LocatorDeviceModule: Unexpected error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    }
  }
}
