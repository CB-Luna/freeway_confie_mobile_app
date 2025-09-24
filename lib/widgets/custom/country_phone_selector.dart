import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeway_app/models/country_phone_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

/// Widget personalizado para seleccionar un país y número de teléfono
/// con prioridad para México, Estados Unidos y Canadá
class CountryPhoneSelector extends StatefulWidget {
  final TextEditingController phoneController;
  final String? initialCountryCode;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<CountryPhoneModel> onCountryChanged;
  final bool showFlag;
  final bool enabled;
  final bool showDropDownIcon;

  const CountryPhoneSelector({
    required this.phoneController,
    required this.onPhoneChanged,
    required this.onCountryChanged,
    super.key,
    this.initialCountryCode = 'US',
    this.labelText,
    this.helperText,
    this.errorText,
    this.showFlag = true,
    this.enabled = true,
    this.showDropDownIcon = true,
  });

  @override
  State<CountryPhoneSelector> createState() => _CountryPhoneSelectorState();
}

class _CountryPhoneSelectorState extends State<CountryPhoneSelector> {
  late CountryPhoneModel _selectedCountry;
  late List<CountryPhoneModel> _countries;
  late List<CountryPhoneModel> _filteredCountries;
  late String _completePhoneNumber;
  final TextEditingController _searchController = TextEditingController();
  late List<TextInputFormatter> _inputFormatters;

  @override
  void initState() {
    super.initState();
    _countries = getOrderedCountries();
    _filteredCountries = List.from(_countries);
    _selectedCountry = _countries.firstWhere(
      (country) => country.code == widget.initialCountryCode,
      orElse: () => _countries.first,
    );
    _completePhoneNumber =
        '${_selectedCountry.formattedDialCode}${widget.phoneController.text}';

    // Inicializar los input formatters según el país seleccionado
    _updateInputFormatters();

    // Configurar el listener para la búsqueda
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
    _searchController.dispose();
    super.dispose();
  }

  // Método para filtrar países según el texto de búsqueda
  void _filterCountries() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // Si no hay consulta, mostrar todos los países en el orden original
        _filteredCountries = List.from(_countries);
      } else {
        // Filtrar países por nombre o código de marcación
        _filteredCountries = _countries
            .where(
              (country) =>
                  country.name.toLowerCase().contains(query) ||
                  country.dialCode.contains(query),
            )
            .toList();
      }
    });
  }

  void _updatePhoneNumber(String value) {
    setState(() {
      _completePhoneNumber = '${_selectedCountry.formattedDialCode}$value';
    });
    widget.onPhoneChanged(_completePhoneNumber);
  }

  /// Actualiza los input formatters según el país seleccionado
  void _updateInputFormatters() {
    _inputFormatters = [
      // Solo permitir dígitos
      FilteringTextInputFormatter.digitsOnly,
      // Formatter personalizado según el país (incluye la limitación de longitud)
      _getCountrySpecificFormatter(_selectedCountry),
    ];
  }

  /// Obtiene un formatter específico según el país seleccionado
  TextInputFormatter _getCountrySpecificFormatter(CountryPhoneModel country) {
    // Formatters específicos para países prioritarios
    switch (country.code) {
      case 'US':
      case 'CA':
      case 'MX':
        // Formato unificado para Norteamérica: XXX-XXX-XXXX
        return NorthAmericaPhoneFormatter();
      default:
        // Para otros países, formato internacional: XX-XXXX-XXXX
        return InternationalPhoneFormatter();
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCountryList(),
    );
  }

  Widget _buildCountryList() {
    return DraggableScrollableSheet(
      initialChildSize: 0.32, // Altura exacta para mostrar solo US, MX y CA
      minChildSize: 0.2,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Indicador de arrastre para que el usuario sepa que puede deslizar hacia abajo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    fontSize: responsiveFontSizes.bodyMedium(context),
                  ),
                  hintStyle: TextStyle(
                    fontSize: responsiveFontSizes.bodyLarge(context),
                  ),
                  hintText: context.translate('auth.searchCountry'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Añadir botón para limpiar la búsqueda
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
                // La búsqueda se maneja a través del listener en initState
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: _filteredCountries.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected = country.code == _selectedCountry.code;

                  return ListTile(
                    leading: Text(
                      country.flag,
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontSize: responsiveFontSizes.bodyMedium(context),
                      ),
                    ),
                    trailing: Text(
                      country.formattedDialCode,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSizes.bodyMedium(context),
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: isSelected
                        ? Theme.of(context).primaryColor.withAlpha(25)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                        _completePhoneNumber =
                            '${_selectedCountry.formattedDialCode}${widget.phoneController.text}';
                        // Actualizar los input formatters cuando cambia el país
                        _updateInputFormatters();
                      });
                      widget.onCountryChanged(country);
                      widget.onPhoneChanged(_completePhoneNumber);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.phoneController,
          enabled: widget.enabled,
          keyboardType: TextInputType.phone,
          inputFormatters: _inputFormatters,
          style: TextStyle(
            fontSize: responsiveFontSizes.bodyMedium(context),
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            labelStyle: TextStyle(
              color: AppTheme.getTitleTextColor(context),
              fontSize: responsiveFontSizes.bodyMedium(context),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide:
                  BorderSide(color: AppTheme.getDetailsGreyColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppTheme.getPrimaryColor(context)),
            ),
            filled: true,
            fillColor: AppTheme.getCardColor(context),
            helperStyle: TextStyle(
              color: AppTheme.getTextGreyColor(context),
              fontSize: responsiveFontSizes.helperText(context),
              height: 1.2, // Espaciado de línea más compacto
            ),
            prefixIcon: GestureDetector(
              onTap: widget.enabled ? _showCountryPicker : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showFlag) ...[
                      Text(
                        _selectedCountry.flag,
                        style: TextStyle(
                          fontSize: responsiveFontSizes.bodyLarge(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _selectedCountry.formattedDialCode,
                      style: TextStyle(
                        color: AppTheme.getTitleTextColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSizes.bodyLarge(context),
                      ),
                    ),
                    widget.showDropDownIcon
                        ? const Icon(Icons.arrow_drop_down)
                        : const SizedBox(width: 4),
                    const SizedBox(width: 4),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.withAlpha(128),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onChanged: _updatePhoneNumber,
        ),
      ],
    );
  }
}

/// Formatter para números de teléfono de Norteamérica (México, Estados Unidos y Canadá)
/// Formato: XXX-XXX-XXXX
class NorthAmericaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    // Si está vacío, devolver como está
    if (newText.isEmpty) {
      return newValue;
    }

    // Eliminar cualquier carácter que no sea dígito
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

    // Limitar a 10 dígitos (número local sin código de país)
    // Si ya hay 10 dígitos y el usuario intenta añadir más, mantener los primeros 10
    final limitedDigits =
        digitsOnly.length > 10 ? digitsOnly.substring(0, 10) : digitsOnly;

    var formattedText = '';

    // Aplicar formato XXX-XXX-XXXX
    for (var i = 0; i < limitedDigits.length; i++) {
      if (i == 0) {
        formattedText += limitedDigits[i];
      } else if (i == 3 || i == 6) {
        formattedText += '-${limitedDigits[i]}';
      } else {
        formattedText += limitedDigits[i];
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formatter para números de teléfono internacionales
/// Formato: XXX-XXX-XXXX
class InternationalPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    // Si está vacío, devolver como está
    if (newText.isEmpty) {
      return newValue;
    }

    // Eliminar cualquier carácter que no sea dígito
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

    // Limitar a 10 dígitos (número local sin código de país)
    // Si ya hay 10 dígitos y el usuario intenta añadir más, mantener los primeros 10
    final limitedDigits =
        digitsOnly.length > 10 ? digitsOnly.substring(0, 10) : digitsOnly;

    var formattedText = '';

    // Aplicar formato XXX-XXX-XXXX
    for (var i = 0; i < limitedDigits.length; i++) {
      if (i == 0) {
        formattedText += limitedDigits[i];
      } else if (i == 3 || i == 6) {
        formattedText += '-${limitedDigits[i]}';
      } else {
        formattedText += limitedDigits[i];
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
