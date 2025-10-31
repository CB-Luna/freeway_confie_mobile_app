import 'package:acceptance_app/data/services/auth_service.dart';
import 'package:acceptance_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:acceptance_app/models/country_phone_model.dart';
import 'package:acceptance_app/pages/profile_page.dart';
import 'package:acceptance_app/providers/auth_provider.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/menu/snackbar_help.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/contactcenter/request_call.dart';
import 'package:acceptance_app/widgets/custom/country_phone_selector.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
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
    _firstNameController.dispose();
    _lastNameController.dispose();
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
      setState(() {
        // Usar el nombre guardado si existe, de lo contrario usar el del objeto User
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email ?? '';
        // Usar el número de póliza guardado si existe, de lo contrario usar el del objeto User
        _policyNumberController.text =
            user.hasPolicies ? user.policies.first.policyNumber : '';

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
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
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

  // Método para actualizar el número de teléfono
  Future<void> _updatePhone(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        // Obtener el servicio de autenticación
        final authService = AuthService(Dio());

        // Llamar al método updateUserData del AuthService con solo el número de teléfono
        final Map<String, dynamic> response = await authService.updateUserData(
          username: currentUser.email ?? '',
          firstName: currentUser.firstName,
          lastName: currentUser.lastName,
          phoneNumber: _completePhoneNumber,
          birthDate: DateFormat('yyyy-MM-dd').format(currentUser.birthDate),
          policyNumber: '',
        );

        if (mounted) {
          // Verificar si se requiere verificación de teléfono
          final bool phoneConfirmationSent =
              response['phoneConfirmationSent'] ?? false;

          if (phoneConfirmationSent) {
            // Si se requiere verificación, mostrar el diálogo
            if (!context.mounted) return;
            await _showVerificationDialog(context);
          } else {
            // Si no se requiere verificación, actualizar directamente
            await authProvider.updateUserData(
              phone: _completePhoneNumber,
            );

            // Mostrar mensaje de éxito
            if (!context.mounted) return;
            showAppSnackBar(
              context,
              context.translate('profile.userDataPage.phoneUpdateSuccess'),
              const Duration(seconds: 2),
              backgroundColor: AppTheme.getGreenColor(context),
            );

            setState(() {
              _hasChanges = true; // Marcar que hay cambios para guardar
            });
          }
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        context.translate('profile.userDataPage.saveError'),
        const Duration(seconds: 2),
        backgroundColor: AppTheme.getRedColor(context),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para mostrar el diálogo de verificación de código
  Future<void> _showVerificationDialog(BuildContext context) async {
    // Resetear el controlador del código de verificación
    _verificationCodeController.clear();

    // Mostrar un SnackBar indicando que se envió un código
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      context.translate(
        'profile.userDataPage.phoneUpdateRequiresVerification',
      ),
      const Duration(seconds: 3),
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
                if (!context.mounted) return;
                showAppSnackBar(
                  context,
                  context.translate('profile.userDataPage.phoneUpdateSuccess'),
                  const Duration(seconds: 3),
                  backgroundColor: AppTheme.getGreenColor(context),
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
      // Mostrar el indicador de carga
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser != null) {
          // Formatear la fecha de nacimiento al formato requerido por la API (yyyy-MM-dd)
          final String formattedBirthDate =
              DateFormat('yyyy-MM-dd').format(_birthDate);

          // Obtener el servicio de autenticación
          final authService = AuthService(Dio());

          // Llamar al método updateUserData del AuthService
          await authService.updateUserData(
            username: currentUser.email ?? '',
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            phoneNumber: _completePhoneNumber,
            birthDate: formattedBirthDate,
            policyNumber: _policyNumberController.text,
          );

          // Continuamos con el flujo normal ya que estamos guardando todos los cambios

          // Si no hay excepciones, consideramos que fue exitoso
          if (mounted) {
            // Actualizar el objeto User completo en el provider
            await authProvider.updateUserData(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              phone: _completePhoneNumber,
              birthDate: _birthDate,
              street: _streetController.text,
              city: _cityController.text,
              state: _stateController.text,
              zipCode: _zipCodeController.text,
            );

            // Nota: El método updateUserData ya maneja la actualización del fullName y la notificación a los listeners

            // Cerrar el LoadingView
            if (mounted && Navigator.canPop(context)) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            }

            if (!mounted) return;

            // Mostrar mensaje de éxito
            showAppSnackBar(
              context,
              context.translate('profile.userDataPage.saveSuccess'),
              const Duration(seconds: 2),
              backgroundColor: AppTheme.getGreenColor(context),
            );

            // Resetear el estado de cambios
            setState(() {
              _hasChanges = false;
            });
          } else {
            // Cerrar el LoadingView en caso de error
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Mostrar mensaje de error
            if (!mounted) return;
            showAppSnackBar(
              context,
              context.translate('profile.userDataPage.saveError'),
              const Duration(seconds: 2),
              backgroundColor: AppTheme.getRedColor(context),
            );
          }
        }
      } catch (e) {
        // Cerrar el LoadingView en caso de error
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (!mounted) return;
        showAppSnackBar(
          context,
          context.translate('profile.userDataPage.saveError'),
          const Duration(seconds: 2),
          backgroundColor: AppTheme.getRedColor(context),
        );
      } finally {
        // Actualizar estado para indicar que ya no está cargando
        if (mounted) {
          setState(() {
            _isLoading = false;
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
                // Llamar al método que maneja la actualización del teléfono
                _updatePhone(context);
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
              controller: _firstNameController,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: context.translate('profile.userDataPage.firstName'),
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
            TextFormField(
              controller: _lastNameController,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: context.translate('profile.userDataPage.lastName'),
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
