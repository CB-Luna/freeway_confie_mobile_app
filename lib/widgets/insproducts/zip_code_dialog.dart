import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

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
      // Asegurar que el contenido se desplace cuando aparece el teclado
      enableDrag: true,
      // Evitar que el teclado oculte el contenido
      useSafeArea: true,
      builder: (BuildContext context) {
        // Obtener el tamaño del teclado para ajustar el tamaño del diálogo
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        // Calcular el tamaño inicial basado en si el teclado está visible
        final initialSize = keyboardHeight > 0
            ? 0.8 // Tamaño mayor cuando el teclado está visible
            : 0.6; // Tamaño normal cuando el teclado no está visible

        return DraggableScrollableSheet(
          initialChildSize: initialSize,
          minChildSize: 0.3,
          maxChildSize: 0.9, // Aumentar el tamaño máximo
          builder: (_, controller) {
            return ZipCodeDialog(
              initialZipCode: initialZipCode,
              onContinue: (zipCode) {
                // Cerrar el teclado antes de cerrar el diálogo
                FocusScope.of(context).unfocus();
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
    // Obtener el tamaño del teclado para ajustar el padding
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return GestureDetector(
      // Cerrar el teclado al tocar fuera del campo de texto
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          // Ajustar el padding para dar más espacio cuando el teclado está visible
          padding: const EdgeInsets.fromLTRB(
            20.0,
            20.0,
            20.0,
            20.0,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de arrastre
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getDetailsGreyColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Título
                Text(
                  context.translate(
                    'vehicleInsurance.location.zipCodeDialogTitle',
                  ),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTitleTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Subtítulo
                Text(
                  context.translate(
                    'vehicleInsurance.location.zipCodeDialogMessage',
                  ),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 14,
                    color: AppTheme.getSubtitleTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Campo de entrada de ZipCode
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: InputDecoration(
                      labelText: context
                          .translate('vehicleInsurance.location.zipCodeHint'),
                      border: InputBorder.none,
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: AppTheme.getDetailsGreyColor(context),
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                    ),
                  ),
                ),
                // Añadir espacio adicional cuando el teclado está visible
                SizedBox(height: isKeyboardVisible ? 40 : 30),
                // Botón de continuar
                ElevatedButton(
                  onPressed: _isZipCodeValid
                      ? () => widget.onContinue(_zipCodeController.text)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isZipCodeValid
                        ? AppTheme.getPrimaryColor(context)
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    context
                        .translate('vehicleInsurance.location.continueButton'),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isZipCodeValid ? AppTheme.white : Colors.white70,
                    ),
                  ),
                ),
                // Espacio adicional al final para asegurar que el botón sea visible
                // incluso cuando el teclado está visible
                SizedBox(height: isKeyboardVisible ? keyboardHeight + 20 : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
