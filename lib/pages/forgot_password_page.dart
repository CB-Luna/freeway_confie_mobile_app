// ignore_for_file: use_build_context_synchronously

import 'package:acceptance_app/data/constants.dart';
import 'package:acceptance_app/data/services/auth_service.dart';
import 'package:acceptance_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:acceptance_app/pages/login_page.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/menu/snackbar_help.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/errors/api_error.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService(
    Dio(
      BaseOptions(
        baseUrl: envLogin,
        headers: {
          'X-API-KEY': apiKeyLogin,
          'Content-Type': 'application/json',
        },
      ),
    ),
  );

  bool _isLoading = false;
  bool _codeSent = false;
  bool _obscureNewPassword =
      true; // Para controlar la visibilidad de la nueva contraseña
  bool _obscureConfirmPassword =
      true; // Para controlar la visibilidad de la confirmación
  String _errorMessage = '';
  String _verificationType = 'SmsCode'; // Por defecto usamos email

  @override
  void dispose() {
    _usernameController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Método para enviar el código de recuperación
  Future<void> _handleSendCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final success = await _authService.sendForgotPasswordMessage(
          userName: _usernameController.text.trim(),
          verificationType: _verificationType,
        );

        setState(() {
          _isLoading = false;
          _codeSent = success;
        });

        if (success) {
          // Mostrar mensaje de éxito
          showAppSnackBar(
            context,
            _verificationType == 'EmailCode'
                ? context.translate('auth.resetPasswordEmailSent')
                : context.translate('auth.resetPasswordSmsSent'),
            const Duration(seconds: 2),
            backgroundColor: Colors.green,
          );
        }
      } on ApiError catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });

        showAppSnackBar(
          context,
          _errorMessage,
          const Duration(seconds: 2),
          backgroundColor: Colors.red,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        showAppSnackBar(
          context,
          _errorMessage,
          const Duration(seconds: 2),
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Método para restablecer la contraseña con el código
  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final success = await _authService.resetPassword(
          userName: _usernameController.text.trim(),
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Mostrar mensaje de éxito
          showAppSnackBar(
            context,
            context.translate('auth.passwordResetSuccessful'),
            const Duration(seconds: 2),
            backgroundColor: Colors.green,
          );

          // Navegar a la pantalla de login después de un breve retraso
          await Future.delayed(const Duration(seconds: 2));
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      } on ApiError catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });

        showAppSnackBar(
          context,
          _errorMessage,
          const Duration(seconds: 2),
          backgroundColor: Colors.red,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        showAppSnackBar(
          context,
          _errorMessage,
          const Duration(seconds: 2),
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsiveFontSizes = ResponsiveFontSizes();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getPrimaryColor(context),
        title: Text(
          context.translate('auth.forgotPasswordTitle'),
          style: TextStyle(
            color: Colors.white,
            fontSize: responsiveFontSizes.titleLarge(context),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? LoadingView(message: context.translate('common.loadingGif'))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _codeSent
                            ? context
                                .translate('auth.resetPasswordCodeInstructions')
                            : context
                                .translate('auth.forgotPasswordInstructions'),
                        style: TextStyle(
                          fontSize: responsiveFontSizes.bodyMedium(context),
                          color: AppTheme.getTextGreyColor(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    fontSize:
                                        responsiveFontSizes.bodyMedium(context),
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Campo de nombre de usuario (siempre visible)
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              enabled:
                                  !_codeSent, // Deshabilitar después de enviar el código
                              decoration: InputDecoration(
                                labelText: context.translate('auth.email'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return context
                                      .translate('auth.pleaseEnterEmail');
                                }
                                // Validación básica de email
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return context
                                      .translate('auth.pleaseEnterValidEmail');
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Convertir a minúsculas automáticamente
                                final newValue = value.toLowerCase();
                                if (value != newValue) {
                                  _usernameController.value = TextEditingValue(
                                    text: newValue,
                                    selection: TextSelection.collapsed(
                                      offset: newValue.length,
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Selector de tipo de verificación (email o SMS)
                            if (!_codeSent) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        context
                                            .translate('auth.verificationSms'),
                                        style: TextStyle(
                                          fontSize: responsiveFontSizes
                                              .bodyMedium(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      value: 'SmsCode',
                                      groupValue: _verificationType,
                                      onChanged: (value) {
                                        setState(() {
                                          _verificationType = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        context.translate(
                                          'auth.verificationEmail',
                                        ),
                                        style: TextStyle(
                                          fontSize: responsiveFontSizes
                                              .bodyMedium(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      value: 'EmailCode',
                                      groupValue: _verificationType,
                                      onChanged: (value) {
                                        setState(() {
                                          _verificationType = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Campos adicionales que aparecen después de enviar el código
                            if (_codeSent) ...[
                              // Campo para el código de verificación
                              TextFormField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  labelText: context
                                      .translate('auth.verificationCode'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_clock),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context
                                        .translate('auth.pleaseEnterCode');
                                  }
                                  if (value.length != 6) {
                                    return context
                                        .translate('auth.invalidCodeLength');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Campo para la nueva contraseña
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                decoration: InputDecoration(
                                  labelText:
                                      context.translate('auth.newPassword'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.translate(
                                      'auth.pleaseEnterNewPassword',
                                    );
                                  }
                                  if (value.length < 8) {
                                    return context
                                        .translate('auth.passwordTooShort');
                                  }
                                  // Validar complejidad de la contraseña
                                  if (!RegExp(
                                    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$',
                                  ).hasMatch(value)) {
                                    return context
                                        .translate('auth.passwordRequirements');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Campo para confirmar la nueva contraseña
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText:
                                      context.translate('auth.confirmPassword'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.translate(
                                      'auth.pleaseConfirmPassword',
                                    );
                                  }
                                  if (value != _newPasswordController.text) {
                                    return context
                                        .translate('auth.passwordsDoNotMatch');
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Botón principal (cambia según el paso)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _codeSent
                                    ? _handleResetPassword
                                    : _handleSendCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.getPrimaryColor(context),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: TextStyle(
                                    fontSize:
                                        responsiveFontSizes.bodyLarge(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _codeSent
                                      ? context
                                          .translate('auth.resetPasswordButton')
                                      : context.translate(
                                          'auth.sendVerificationCode',
                                        ),
                                ),
                              ),
                            ),

                            // Botón para volver atrás (solo visible después de enviar el código)
                            if (_codeSent) ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _codeSent = false;
                                    _codeController.clear();
                                    _newPasswordController.clear();
                                    _confirmPasswordController.clear();
                                    _errorMessage = '';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppTheme.getPrimaryColor(context),
                                ),
                                child: Text(
                                  context.translate('auth.backToSendCode'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
