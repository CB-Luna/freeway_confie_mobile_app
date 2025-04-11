import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
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

  // Formateador para el número de teléfono con formato internacional
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+# (###) ###-####',
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
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Método para extraer solo los dígitos del número de teléfono formateado
  String _getFormattedPhoneNumber() {
    // Obtener el número con formato (con máscara)
    final maskedNumber = _phoneController.text;

    // Eliminar todos los caracteres que no sean dígitos o el signo '+'
    final cleanedNumber = maskedNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Asegurarse de que comience con '+'
    return cleanedNumber.startsWith('+') ? cleanedNumber : '+$cleanedNumber';
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signUp(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _passwordController.text,
          _getFormattedPhoneNumber(),
          _policyNumberController.text,
          _birthDateController.text,
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
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.email'),
                    ),
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
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_phoneMaskFormatter],
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.phoneNumber'),
                    ).copyWith(
                      hintText: context.translate('auth.phoneNumberHint'),
                      prefixIcon: const Icon(Icons.phone),
                      helperText: context.translate('auth.phoneNumberHelper'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseEnterPhone');
                      }

                      // Verificar que el número tenga el formato correcto
                      if (!_phoneMaskFormatter.isFill()) {
                        return context
                            .translate('auth.pleaseEnterCompletePhone');
                      }

                      // Verificar que el número limpio tenga el formato correcto para la API
                      final cleanedNumber =
                          value.replaceAll(RegExp(r'[^\d+]'), '');
                      if (!RegExp(r'^\+\d{10,15}$').hasMatch(cleanedNumber)) {
                        return context.translate('auth.phoneNumberFormat');
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: context.translate('auth.birthDate'),
                    ).copyWith(
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('auth.pleaseSelectBirthDate');
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
                    ).copyWith(
                      prefixIcon: const Icon(Icons.policy),
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
