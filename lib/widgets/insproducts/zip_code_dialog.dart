import 'package:flutter/material.dart';

class ZipCodeDialog extends StatefulWidget {
  final String? initialZipCode;
  final Function(String) onContinue;

  const ZipCodeDialog({
    required this.onContinue,
    super.key,
    this.initialZipCode,
  });

  static Future<String?> show({
    required BuildContext context,
    String? initialZipCode,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          builder: (_, controller) {
            return ZipCodeDialog(
              initialZipCode: initialZipCode,
              onContinue: (zipCode) {
                Navigator.pop(context, zipCode);
              },
            );
          },
        );
      },
    );
  }

  @override
  State<ZipCodeDialog> createState() => _ZipCodeDialogState();
}

class _ZipCodeDialogState extends State<ZipCodeDialog> {
  late TextEditingController _zipCodeController;
  bool _isZipCodeValid = false;

  @override
  void initState() {
    super.initState();
    _zipCodeController =
        TextEditingController(text: widget.initialZipCode ?? '');
    _validateZipCode(_zipCodeController.text);
    _zipCodeController.addListener(() {
      _validateZipCode(_zipCodeController.text);
    });
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  void _validateZipCode(String value) {
    // Validar que el código postal tenga 5 dígitos
    setState(() {
      _isZipCodeValid = value.length == 5 && RegExp(r'^\d{5}$').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de arrastre
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Título
            const Text(
              'Enter your ZipCode',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Subtítulo
            const Text(
              'Enter your ZIP code to continue with the process',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Campo de entrada de ZipCode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _zipCodeController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: const InputDecoration(
                  labelText: 'ZipCode',
                  border: InputBorder.none,
                  counterText: '',
                ),
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Botón de continuar
            ElevatedButton(
              onPressed: _isZipCodeValid
                  ? () => widget.onContinue(_zipCodeController.text)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.blue.withValues(alpha: 0.5),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
