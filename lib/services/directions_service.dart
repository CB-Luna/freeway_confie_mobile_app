import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/office_location.dart';
import '../widgets/location/location_zipcode_page.dart';

class DirectionsService {
  /// Solicita permisos de ubicación y abre la navegación hacia la oficina
  static Future<void> navigateToOffice(
    BuildContext context,
    OfficeLocation office,
  ) async {
    // Capturar el contexto en una variable local para evitar problemas con el contexto
    // cuando se usa en operaciones asíncronas
    final scaffoldContext = context;

    try {
      // Verificar si los servicios de ubicación están habilitados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Verificar si el contexto sigue siendo válido
        if (scaffoldContext.mounted) {
          _showErrorDialog(
            scaffoldContext,
            'Los servicios de ubicación están desactivados',
            'Por favor, active los servicios de ubicación para obtener direcciones.',
          );
        }
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Verificar si el contexto sigue siendo válido
          if (scaffoldContext.mounted) {
            _showErrorDialog(
              scaffoldContext,
              'Permiso de ubicación denegado',
              'Se requiere acceso a la ubicación para proporcionar direcciones precisas.',
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Verificar si el contexto sigue siendo válido
        if (scaffoldContext.mounted) {
          _showErrorDialog(
            scaffoldContext,
            'Permiso de ubicación denegado permanentemente',
            'Por favor, habilite los permisos de ubicación en la configuración de su dispositivo.',
          );
        }
        return;
      }

      // Mostrar diálogo de carga solo si el contexto sigue siendo válido
      if (scaffoldContext.mounted) {
        _showLoadingDialog(scaffoldContext);
      } else {
        return; // Si el contexto ya no es válido, salir del método
      }

      // Obtener la ubicación actual
      final Position position = await Geolocator.getCurrentPosition();

      // Cerrar diálogo de carga solo si el contexto sigue siendo válido
      if (scaffoldContext.mounted) {
        Navigator.of(scaffoldContext).pop();
      } else {
        return; // Si el contexto ya no es válido, salir del método
      }

      // Construir URL para Google Maps con origen y destino
      final url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${position.latitude},${position.longitude}'
          '&destination=${office.latitude},${office.longitude}'
          '&travelmode=driving';

      // Lanzar la URL
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Si no se puede abrir Google Maps, intentar con la URL básica
        final fallbackUrl =
            'https://www.google.com/maps/dir/?api=1&destination=${office.latitude},${office.longitude}';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          // Verificar si el contexto sigue siendo válido
          if (scaffoldContext.mounted) {
            _showErrorDialog(
              scaffoldContext,
              'No se pudo abrir el navegador',
              'No se pudo abrir la aplicación de mapas. Por favor, intente nuevamente.',
            );
          }
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto y el contexto es válido
      if (scaffoldContext.mounted && Navigator.canPop(scaffoldContext)) {
        Navigator.of(scaffoldContext).pop();
      }

      // Mostrar error solo si el contexto sigue siendo válido
      if (scaffoldContext.mounted) {
        _showErrorDialog(
          scaffoldContext,
          'Error al obtener direcciones',
          'Ocurrió un error al intentar obtener direcciones: ${e.toString()}',
        );
      }
    }
  }

  // Mostrar diálogo de error
  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo de carga
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Obteniendo su ubicación...'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para navegar a la página de código postal
  static void navigateToZipCodePage(
    BuildContext context,
    OfficeLocation office,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationZipCodePage(office: office),
      ),
    );
  }
}
