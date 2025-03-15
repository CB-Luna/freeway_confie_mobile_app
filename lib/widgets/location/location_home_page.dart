import 'package:flutter/material.dart';

import '../../locatordevice/di/injection_container.dart' as di;
import '../../locatordevice/locator_device_module.dart';

class LocationHomePage extends StatefulWidget {
  const LocationHomePage({super.key});

  @override
  State<LocationHomePage> createState() => _LocationHomePageState();
}

class _LocationHomePageState extends State<LocationHomePage> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      if (!di.sl.isRegistered<di.ServiceLocator>()) {
        await di.init();
      }

      if (mounted) {
        await LocatorDeviceModule.navigateToLocationView(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing location services: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
