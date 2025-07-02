import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/models/country_phone_model.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/contactcenter/request_call.dart';
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  // Almacena el número completo con código de país - usado para guardar en el perfil
  String _completePhoneNumber = '';
  CountryPhoneModel _selectedCountry = countryPhoneList.first;
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;
  DateTime _birthDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Usar un Future.microtask para llamar al método asíncrono después de que el widget esté montado
    Future.microtask(() async {
      await _loadUserData();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _policyNumberController.dispose();
    _verificationCodeController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      // Obtener el nombre y número de póliza guardados en el almacenamiento seguro
      final String? savedName = await authProvider.getFullName();

      setState(() {
        // Usar el nombre guardado si existe, de lo contrario usar el del objeto User
        _fullNameController.text = savedName ?? user.fullName;
        _emailController.text = user.email ?? '';
        // Usar el número de póliza guardado si existe, de lo contrario usar el del objeto User
        _policyNumberController.text = user.policies.first.policyNumber;

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
    _policyNumberController.addListener(_onFieldChanged);
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
    setState(() {
      _selectedCountry = country;
    });
  }

  // Método para mostrar el diálogo de verificación de código
  Future<void> _showVerificationDialog(BuildContext context) async {
    // Resetear el controlador del código de verificación
    _verificationCodeController.clear();

    // Mostrar un SnackBar indicando que se envió un código
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.translate(
            'profile.userDataPage.phoneUpdateRequiresVerification',
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Mostrar el diálogo para ingresar el código
    await showDialog(
      context: context,
      barrierDismissible: false, // El usuario debe interactuar con el diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            context.translate('profile.userDataPage.enterVerificationCode'),
            style: TextStyle(
              fontSize: responsiveFontSizes.titleMedium(context),
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate('profile.userDataPage.verificationCodeSent'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _verificationCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText: context
                      .translate('profile.userDataPage.verificationCode'),
                ),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyLarge(context),
                  letterSpacing:
                      8.0, // Espaciado entre caracteres para mejor legibilidad
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                context.translate('cancel'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para verificar el código
                // Por ahora, simplemente cerramos el diálogo y mostramos un mensaje de éxito
                Navigator.of(context).pop(); // Cerrar el diálogo

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context
                          .translate('profile.userDataPage.phoneUpdateSuccess'),
                    ),
                    backgroundColor: AppTheme.getGreenColor(context),
                    duration: const Duration(seconds: 3),
                  ),
                );

                setState(() {
                  _hasChanges = true; // Marcar que hay cambios para guardar
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getPrimaryColor(context),
                foregroundColor: Colors.white,
              ),
              child: Text(
                context.translate('auth.twoFactorSubmit'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          // En una implementación real, estos valores se enviarían a la API
          // y se actualizaría el usuario en el backend
          // Por ahora solo simulamos la actualización

          // Guardar el nombre completo y número de póliza actualizados en el almacenamiento seguro
          // Esto también actualizará el objeto User y notificará a los listeners
          await authProvider.saveFullName(_fullNameController.text);

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

  // Método para navegar a la página de contacto del agente
  void _contactAgent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestCallPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
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
      ),
      body: _isLoading
          ? const Center(child: LoadingView())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPersonalInfoCard(context),
                    _buildSaveButton(context),
                    _buildPhoneCard(context),
                    _buildAddressCard(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPhoneCard(BuildContext context) {
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
              context.translate('profile.userDataPage.phoneManagement'),
              style: TextStyle(
                fontSize: responsiveFontSizes.titleLarge(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryColor(context),
              ),
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
            // Botón para actualizar el número de teléfono
            ElevatedButton(
              onPressed: () {
                // Mostrar el diálogo para ingresar el código de verificación
                _showVerificationDialog(context);
              },
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
                context.translate('profile.userDataPage.updatePhone'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.translate(
                'profile.userDataPage.phoneVerificationDescription',
              ),
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
                    color: AppTheme.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de número de póliza
            TextFormField(
              controller: _policyNumberController,
              decoration: AppTheme.inputDecoration(
                context,
                labelText:
                    context.translate('profile.userDataPage.policyNumber'),
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
