import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/office_location.dart';
import '../../utils/menu/circle_nav_bar.dart';

class LocationZipCodePage extends StatefulWidget {
  final OfficeLocation office;

  const LocationZipCodePage({
    required this.office, super.key,
  });

  @override
  State<LocationZipCodePage> createState() => _LocationZipCodePageState();
}

class _LocationZipCodePageState extends State<LocationZipCodePage> {
  final TextEditingController _zipCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  // Método para manejar la acción de búsqueda
  Future<void> _handleSearch() async {
    final zipCode = _zipCodeController.text.trim();
    if (zipCode.isEmpty) {
      _showErrorMessage('Please enter your Zip Code');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Construir URL para Google Maps con código postal como origen
      final url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=$zipCode'
          '&destination=${widget.office.latitude},${widget.office.longitude}'
          '&travelmode=driving';

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Regresar a la pantalla anterior después de lanzar el mapa
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showErrorMessage('Could not open maps application');
      }
    } catch (e) {
      _showErrorMessage('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para manejar la acción de usar ubicación actual
  Future<void> _handleUseCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Verificar si los servicios de ubicación están habilitados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorMessage('Location services are disabled');
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorMessage('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorMessage('Location permissions are permanently denied');
        return;
      }

      // Obtener la ubicación actual
      final Position position = await Geolocator.getCurrentPosition();

      // Construir URL para Google Maps con origen y destino
      final url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${position.latitude},${position.longitude}'
          '&destination=${widget.office.latitude},${widget.office.longitude}'
          '&travelmode=driving';

      // Lanzar la URL
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Regresar a la pantalla anterior después de lanzar el mapa
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showErrorMessage('Could not open maps application');
      }
    } catch (e) {
      _showErrorMessage('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A4DA2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/auth/freeway_logo.png',
          height: 30,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fondo del mapa (simulado)
          Container(
            color: const Color(
                0xFFE6F0F5,), // Color azul claro para simular el mapa
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF0A4DA2),
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Geo-Detection not available.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Please enter your Zip Code.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Panel inferior con campo de entrada y botones
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fila con campo de entrada y botón de búsqueda en el mismo renglón
                      Row(
                        children: [
                          // Campo de entrada para el código postal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _zipCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your Zip Code',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Open Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none, // Sin recuadro
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                // Línea debajo del texto
                                Container(
                                  height: 1,
                                  color: const Color(
                                      0xFF157EAD,), // Mismo color que el botón Search
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Botón de búsqueda
                          SizedBox(
                            width: 126, // Ancho específico
                            height: 45, // Alto específico
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                    0xFF157EAD,), // Color azul claro actualizado
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white,),
                                      ),
                                    )
                                  : const Text(
                                      'Search',
                                      style: TextStyle(
                                        fontFamily: 'Open Sans',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Botón para usar ubicación actual
                      SizedBox(
                        width: double
                            .infinity, // w25 hug (se ajustará al contenido con padding)
                        height: 48, // Altura específica
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoading ? null : _handleUseCurrentLocation,
                          icon: const Icon(
                            Icons
                                .location_on_outlined, // Icono de ubicación outline
                            color: Color(0xFF0A4DA2), // Color azul
                            size: 24, // Tamaño específico w24 h24
                          ),
                          label: const Text(
                            'Use my current location',
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600, // SemiBold
                              color: Color(0xFF0A4DA2), // Color azul
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,), // Padding específico
                            side: const BorderSide(color: Color(0xFF0A4DA2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(77), // 0.3 * 255 = 76.5 ≈ 77
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Transform.translate(
        offset: const Offset(0, -20), // Subir el menú 20px
        child: CircleNavBar(
          selectedPos: 2, // Índice para la ubicación
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/add-insurance');
            }
          },
          tabItems: [
            TabData(Icons.home_outlined, 'My Products'),
            TabData(Icons.verified_user_outlined, '+ Add Insurance'),
            TabData(Icons.location_on_outlined, 'Location'),
          ],
        ),
      ),
    );
  }
}
