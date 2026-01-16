import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../controllers/location_controller.dart';

class ZipCodeInputView extends StatefulWidget {
  final VoidCallback? onUseCurrentLocation;

  const ZipCodeInputView({
    super.key,
    this.onUseCurrentLocation,
  });

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
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mensaje de error
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 24.0),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getBoxShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppTheme.getRedColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context
                        .translate('office.zipCode.geoDetectionNotAvailable'),
                    style: TextStyle(
                      color: AppTheme.getRedColor(context),
                      fontWeight: FontWeight.w500,
                      fontSize: responsiveFontSizes.bodyMedium(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Título
          Text(
            context.translate('office.zipCode.enterZipCode'),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyLarge(context),
              fontWeight: FontWeight.w600,
              color: AppTheme.getTitleTextColor(context),
            ),
          ),
          const SizedBox(height: 16),

          // Campo de entrada de código postal
          TextField(
            controller: _zipController,
            focusNode: _zipFocusNode,
            keyboardType: TextInputType.number,
            maxLength: 5,
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyMedium(context),
            ),
            decoration: InputDecoration(
              hintText: context.translate('office.zipCode.zipCodeHint'),
              counterText: '',
              filled: true,
              fillColor: AppTheme.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: AppTheme.getDetailsGreyColor(context),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: AppTheme.getPrimaryColor(context),
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
                backgroundColor: AppTheme.getPrimaryColor(context),
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                context.translate('office.zipCode.search'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.button(context),
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
            icon: Icon(
              Icons.my_location,
              color: AppTheme.getPrimaryColor(context),
            ),
            label: Text(
              context.translate('office.zipCode.useMyLocation'),
              style: TextStyle(
                color: AppTheme.getPrimaryColor(context),
                fontWeight: FontWeight.w600,
                fontSize: responsiveFontSizes.bodyMedium(context),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.getPrimaryColor(context)),
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
    if (zipCode.isEmpty ||
        zipCode.length != 5 ||
        !RegExp(r'^[0-9]{5}$').hasMatch(zipCode)) {
      showAppSnackBar(
        context,
        context.translate('office.zipCode.invalidZipCode'),
        const Duration(seconds: 2),
        backgroundColor: AppTheme.getRedColor(context),
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
    showAppSnackBar(
      context,
      context.translateWithArgs(
        'office.zipCode.searchingNear',
        args: [zipCode],
      ),
      const Duration(seconds: 2),
      backgroundColor: AppTheme.getBlueColor(context),
    );

    // Llamar al método de búsqueda por código postal
    locationController.searchByZipCode(zipCode, context).then((_) {
      // Después de que termine la búsqueda, verificar si hay un mensaje de error
      final errorMessage = locationController.state.errorMessage;
      if (errorMessage != null && errorMessage.startsWith('noOfficesFound:')) {
        final searchedZipCode = errorMessage.split(':')[1];
        // Mostrar dialog con el mensaje
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.getOrangeColor(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.translate('office.zipCode.search'),
                        style: TextStyle(
                          color: AppTheme.getOrangeColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  context.translateWithArgs(
                    'office.zipCode.noOfficesFound',
                    args: [searchedZipCode],
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      context.translate('common.ok'),
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }
}
