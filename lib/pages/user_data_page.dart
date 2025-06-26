import 'package:flutter/material.dart';
import 'package:freeway_app/models/country_phone_model.dart';
import 'package:freeway_app/pages/webview_page.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/custom/country_phone_selector.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  // Almacena el número completo con código de país - usado para guardar en el perfil
  String _completePhoneNumber = '';
  CountryPhoneModel _selectedCountry = countryPhoneList.first;
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;
  DateTime _birthDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      setState(() {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email ?? '';

        // Extraer el número de teléfono sin el código de país
        if (user.phone != null && user.phone!.isNotEmpty) {
          // Usamos ! porque ya verificamos que no es nulo
          // Intentar detectar el código de país del número de teléfono
          final String phoneNumber = '1${user.phone!}';
          var foundCountry = false;

          // Buscar un país que coincida con el prefijo del número
          for (final country in countryPhoneList) {
            final String dialCode = country.dialCode.replaceAll('+', '');
            if (phoneNumber.startsWith(dialCode)) {
              _selectedCountry = country;
              // Eliminar el código de país del número
              _phoneController.text = phoneNumber.substring(dialCode.length);
              foundCountry = true;
              break;
            }
          }

          // Si no se encontró un código de país, usar el número tal cual
          if (!foundCountry) {
            _phoneController.text = phoneNumber;
          }
          _completePhoneNumber = user.phone!;
        }

        _birthDate = user.birthDate;
        _streetController.text = user.street;
        _cityController.text = user.city;
        _stateController.text = user.state;
        _zipCodeController.text = user.zipCode;
      });
    }

    // Añadir listeners para detectar cambios
    _fullNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _streetController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
    _zipCodeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  // Método para actualizar el número de teléfono completo
  void _updateCompletePhoneNumber(String number) {
    setState(() {
      _completePhoneNumber = number;
      _hasChanges = true;
    });
    // Aquí se podría realizar alguna validación adicional del número
    // o formateo específico si fuera necesario
  }

  // Método para actualizar el país seleccionado
  void _updateSelectedCountry(CountryPhoneModel country) {
    _selectedCountry = country;
    _onFieldChanged();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulamos una llamada a la API para guardar los cambios
        await Future.delayed(const Duration(seconds: 1));

        // Actualizamos los datos del usuario en el provider
        if (!mounted) return;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser != null) {
          // En una implementación real, aquí se enviarían los datos actualizados a la API
          // incluyendo el número de teléfono completo (_completePhoneNumber)

          // En una implementación real, estos valores se enviarían a la API
          // y se actualizaría el usuario en el backend
          // Por ahora solo simulamos la actualización

          // Usamos _completePhoneNumber para la actualización del perfil
          final dataToUpdate = {
            'fullName': _fullNameController.text,
            'birthDate': _birthDate,
            'phone': _completePhoneNumber,
          };

          // Ejemplo de cómo se usarían los valores en una actualización real:
          // await userService.updateUserProfile(dataToUpdate);

          // Nota: No podemos actualizar directamente el objeto User porque no tiene un setter
          // y el AuthProvider no tiene un método updateCurrentUser
          // En una implementación real, se llamaría a un método del AuthProvider para actualizar el usuario

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.translate('profile.userDataPage.saveSuccess'),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.translate('profile.userDataPage.saveError'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasChanges = false;
          });
        }
      }
    }
  }

  // Método para abrir el WebView con la página de contacto del agente
  void _contactAgent(BuildContext context) {
    // URL de ejemplo para contactar al agente
    const String agentContactUrl =
        'https://www.freewayinsurance.com/contact-us';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: agentContactUrl,
          title: context.translate('profile.userDataPage.contactAgent'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 56,
        title: Text(
          context.translate('profile.dataUser'),
          style: TextStyle(
            color: AppTheme.white,
            fontSize: responsiveFontSizes.titleMedium(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: AppTheme.getBackgroundColor(context),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildPersonalInfoCard(context),
                    const SizedBox(height: 10),
                    _buildSaveButton(context),
                    const SizedBox(height: 10),
                    _buildAddressCard(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('profile.userDataPage.userData'),
              style: TextStyle(
                fontSize: responsiveFontSizes.titleLarge(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: context.translate('profile.userDataPage.fullName'),
              ),
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.translate('validation.requiredField');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Selector de país y número de teléfono
            CountryPhoneSelector(
              phoneController: _phoneController,
              initialCountryCode: _selectedCountry.code,
              labelText: context.translate('profile.userDataPage.phone'),
              onPhoneChanged: _updateCompletePhoneNumber,
              onCountryChanged: _updateSelectedCountry,
            ),
            const SizedBox(height: 16),
            // Campo de fecha de nacimiento con formato MM/DD/YYYY
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.getPrimaryColor(context),
                          onPrimary: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _birthDate) {
                  setState(() {
                    _birthDate = picked;
                    _hasChanges = true;
                  });
                }
              },
              child: InputDecorator(
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText:
                      context.translate('profile.userDataPage.birthDate'),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  // Formato MM/DD/YYYY
                  '${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.year}',
                  style: TextStyle(
                    fontSize: responsiveFontSizes.bodyMedium(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('profile.userDataPage.addressData'),
              style: TextStyle(
                fontSize: responsiveFontSizes.titleMedium(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de email (solo lectura)
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              enabled: false,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: context.translate('profile.userDataPage.email'),
              ),
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
                color: AppTheme.getTextGreyColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de dirección (solo lectura)
            TextFormField(
              controller: _streetController,
              readOnly: true,
              enabled: false,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: context.translate('profile.userDataPage.street'),
              ),
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
                color: AppTheme.getTextGreyColor(context),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de ciudad (solo lectura)
            TextFormField(
              controller: _cityController,
              readOnly: true,
              enabled: false,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: context.translate('profile.userDataPage.city'),
              ),
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
                color: AppTheme.getTextGreyColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Campo de estado (solo lectura)
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    readOnly: true,
                    enabled: false,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText:
                          context.translate('profile.userDataPage.state'),
                    ),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.bodyMedium(context),
                      color: AppTheme.getTextGreyColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Campo de código postal (solo lectura)
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    enabled: false,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText:
                          context.translate('profile.userDataPage.zipCode'),
                    ),
                    style: TextStyle(
                      fontSize: responsiveFontSizes.bodyMedium(context),
                      color: AppTheme.getTextGreyColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Botón para contactar al agente
            ElevatedButton(
              onPressed: () => _contactAgent(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getBlueColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: Text(
                context.translate('profile.userDataPage.contactAgent'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.translate('profile.userDataPage.contactAgentDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsiveFontSizes.bodySmall(context),
                color: AppTheme.getTextGreyColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final primaryColor = AppTheme.getGreenColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: _hasChanges && !_isLoading ? _saveChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          disabledBackgroundColor: primaryColor.withAlpha(128),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          context.translate('profile.userDataPage.save'),
          style: TextStyle(
            fontSize: responsiveFontSizes.bodyLarge(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
