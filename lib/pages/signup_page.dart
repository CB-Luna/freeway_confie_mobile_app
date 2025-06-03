import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/models/country_phone_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/custom/country_phone_selector.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/theme/app_theme.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  DateTime? _selectedDate;
  String _completePhoneNumber =
      ''; // Almacena el número completo con código de país
  CountryPhoneModel _selectedCountry = countryPhoneList.first;

  // Formateador para la fecha de nacimiento en formato estadounidense (MMDDYYYY)
  final _birthDateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    // Dar foco al campo First Name cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstNameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _policyNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Formatear la fecha en formato estadounidense (MM/DD/YYYY)
        _birthDateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  // Método para convertir la fecha de formato MM/DD/YYYY a formato ISO (YYYY-MM-DD) para la API
  String _getFormattedBirthDate() {
    if (_selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(_selectedDate!);
    } else if (_birthDateController.text.isNotEmpty) {
      try {
        // Intentar parsear la fecha ingresada manualmente
        final parts = _birthDateController.text.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]);
          final day = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          if (month != null && day != null && year != null) {
            final date = DateTime(year, month, day);
            return DateFormat('yyyy-MM-dd').format(date);
          }
        }
      } catch (e) {
        // Si hay un error al parsear, devolver la fecha como está
      }
    }
    return _birthDateController.text;
  }

  // Método para extraer el número de teléfono completo con código de país
  String _getFormattedPhoneNumber() {
    // Usar _selectedCountry para asegurar que el código de país sea el correcto
    if (_completePhoneNumber.isEmpty) {
      return '${_selectedCountry.formattedDialCode}${_phoneController.text}';
    }
    return _completePhoneNumber;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Aseguramos que el email siempre se envíe en minúsculas
        final email = _emailController.text.toLowerCase();
        await authProvider.signUp(
          _firstNameController.text,
          _lastNameController.text,
          email,
          _passwordController.text,
          _getFormattedPhoneNumber(),
          _policyNumberController.text,
          _getFormattedBirthDate(), // Usar el método para obtener la fecha en formato ISO
        );

        // Verificar si hay un mensaje de error
        if (authProvider.errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.errorMessage!),
                backgroundColor: AppTheme.getRedColor(context),
              ),
            );
          }
        } else if (mounted) {
          // Si no hay error, navegar a la página de inicio
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.translate('auth.error')}: $e'),
              backgroundColor: AppTheme.getRedColor(context),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      AppTheme.getFreewayLogoType(context),
                      width: 195.65,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.translate('auth.signUp'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTitleTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.firstName'),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_lastNameFocus);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseEnterFirstName');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.lastName'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseEnterLastName');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.email'),
                    ),
                    // Convertir automáticamente a minúsculas mientras el usuario escribe
                    onChanged: (value) {
                      if (value != value.toLowerCase()) {
                        _emailController.value = TextEditingValue(
                          text: value.toLowerCase(),
                          selection: _emailController.selection,
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseEnterEmail');
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return context.translate('auth.pleaseEnterValidEmail');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.password'),
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      // Añadir texto de ayuda para explicar los requisitos de la contraseña
                      helperText:
                          context.translate('auth.passwordRequirements'),
                      helperMaxLines: 3,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseEnterPassword');
                      }
                      if (value.length < 6) {
                        return context.translate('auth.passwordMinLength');
                      }
                      // Verificar si la contraseña tiene al menos una letra mayúscula
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return context.translate('auth.passwordUppercase');
                      }
                      // Verificar si la contraseña tiene al menos un número
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return context.translate('auth.passwordNumber');
                      }
                      // Verificar si la contraseña tiene al menos un carácter especial
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return context.translate('auth.passwordSpecial');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  CountryPhoneSelector(
                    phoneController: _phoneController,
                    labelText: context.translate('auth.phoneNumber'),
                    helperText: context.translate('auth.phoneNumberHelper'),
                    initialCountryCode:
                        'US', // Código de país predeterminado (Estados Unidos)
                    showFlag: true,
                    onPhoneChanged: (completeNumber) {
                      // Actualizar el número completo con código de país cuando cambia
                      setState(() {
                        _completePhoneNumber = completeNumber;
                      });
                    },
                    onCountryChanged: (country) {
                      setState(() {
                        _selectedCountry = country;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthDateController,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.birthDate'),
                    ).copyWith(
                      prefixIcon: const Icon(Icons.calendar_today),
                      helperText: 'MM/DD/YYYY', // Indicar el formato esperado
                    ),
                    inputFormatters: [_birthDateMaskFormatter],
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseSelectBirthDate');
                      }

                      // Validar que la fecha tenga el formato correcto
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        return 'Por favor ingrese la fecha en formato MM/DD/YYYY';
                      }

                      try {
                        // Validar que la fecha sea válida
                        final parts = value.split('/');
                        final month = int.parse(parts[0]);
                        final day = int.parse(parts[1]);
                        final year = int.parse(parts[2]);

                        if (month < 1 || month > 12) {
                          return 'Mes inválido';
                        }

                        if (day < 1 || day > 31) {
                          return 'Día inválido';
                        }

                        if (year < 1900 || year > DateTime.now().year) {
                          return 'Año inválido';
                        }

                        // Validar días según el mes
                        if ((month == 4 ||
                                month == 6 ||
                                month == 9 ||
                                month == 11) &&
                            day > 30) {
                          return 'Este mes solo tiene 30 días';
                        }

                        // Febrero y años bisiestos
                        if (month == 2) {
                          final bool isLeapYear =
                              (year % 4 == 0 && year % 100 != 0) ||
                                  (year % 400 == 0);
                          if (day > (isLeapYear ? 29 : 28)) {
                            return 'Febrero tiene ${isLeapYear ? 29 : 28} días en $year';
                          }
                        }

                        // Guardar la fecha seleccionada
                        _selectedDate ??= DateTime(year, month, day);
                      } catch (e) {
                        return 'Fecha inválida';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _policyNumberController,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.policyNumber'),
                    ),
                    // No hay validación porque es opcional
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: AppTheme.primaryButtonStyle(context),
                    child: _isLoading
                        ? LoadingView(
                            message: context.translate('auth.signUpLoading'),
                          )
                        : Text(
                            context.translate('auth.signUp'),
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.translate('auth.haveAccount'),
                        style: TextStyle(
                          color: AppTheme.getTextGreyColor(context),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          context.translate('auth.loginButton'),
                          style: TextStyle(
                            color: AppTheme.getPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
