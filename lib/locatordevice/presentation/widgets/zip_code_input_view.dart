import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/location_controller.dart';

class ZipCodeInputView extends StatefulWidget {
  final VoidCallback? onUseCurrentLocation;

  const ZipCodeInputView({
    Key? key,
    this.onUseCurrentLocation,
  }) : super(key: key);

  @override
  State<ZipCodeInputView> createState() => _ZipCodeInputViewState();
}

class _ZipCodeInputViewState extends State<ZipCodeInputView> {
  final TextEditingController _zipController = TextEditingController();
  final FocusNode _zipFocusNode = FocusNode();

  @override
  void dispose() {
    _zipController.dispose();
    _zipFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mensaje de error
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Geo-Detection not available. Please enter your Zip Code.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Título
          const Text(
            'Enter your Zip Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de entrada de código postal
          TextField(
            controller: _zipController,
            focusNode: _zipFocusNode,
            keyboardType: TextInputType.number,
            maxLength: 5,
            decoration: InputDecoration(
              hintText: 'Zip Code',
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFF0046B9),
                  width: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón de búsqueda
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _searchByZipCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0046B9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botón para usar ubicación actual
          OutlinedButton.icon(
            onPressed: () {
              if (widget.onUseCurrentLocation != null) {
                widget.onUseCurrentLocation!();
              }
            },
            icon: const Icon(
              Icons.my_location,
              color: Color(0xFF0046B9),
            ),
            label: const Text(
              'Use my current location',
              style: TextStyle(
                color: Color(0xFF0046B9),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0046B9)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _searchByZipCode() {
    final zipCode = _zipController.text.trim();
    
    // Validar que el código postal tenga 5 dígitos
    if (zipCode.isEmpty || zipCode.length != 5 || !RegExp(r'^[0-9]{5}$').hasMatch(zipCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 5-digit zip code'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Obtener el controlador de ubicación
    final locationController = Provider.of<LocationController>(
      context,
      listen: false,
    );

    // Mostrar un mensaje al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for offices near zip code: $zipCode'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
    
    // Llamar al método de búsqueda por código postal
    locationController.searchByZipCode(zipCode);
  }
}
