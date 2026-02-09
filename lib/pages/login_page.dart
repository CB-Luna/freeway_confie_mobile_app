// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/biometric_provider.dart';
import '../widgets/auth/two_factor_dialog.dart';
import '../widgets/theme/app_theme.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _twoFactorCodeController =
      TextEditingController(); // Se mantiene para uso futuro
  bool _isLoading = false;
  bool _obscureText = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  // bool _showTwoFactorInput =
  //     false; // Se mantiene para uso futuro pero siempre será falso

  @override
  void initState() {
    super.initState();
    // Verificar si la biometría está disponible y habilitada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricStatus();
    });
  }

  Future<void> _checkBiometricStatus() async {
    final biometricProvider =
        Provider.of<BiometricProvider>(context, listen: false);

    // Establecer el contexto para las traducciones
    biometricProvider.setContext(context);

    // Forzar una actualización del estado biométrico
    await biometricProvider.refreshBiometricState();

    // Actualizar el estado local con los valores del provider
    if (mounted) {
      setState(() {
        _isBiometricAvailable = biometricProvider.isAvailable;
        _isBiometricEnabled = biometricProvider.isEnabled;
        debugPrint(
          'Estado biométrico actualizado - Disponible: $_isBiometricAvailable, Habilitado: $_isBiometricEnabled',
        );
      });
    }

    // Nota: Eliminamos la autenticación automática por razones de seguridad
    // Es mejor que el usuario inicie manualmente el proceso de autenticación biométrica
  }

  /// Intenta autenticar al usuario usando biometría
  ///
  /// Devuelve true si la autenticación fue exitosa, false en caso contrario
  Future<bool> _authenticateWithBiometrics() async {
    try {
      final biometricProvider =
          Provider.of<BiometricProvider>(context, listen: false);

      // Establecer el contexto para las traducciones
      biometricProvider.setContext(context);

      final success = await biometricProvider.authenticate();

      if (!success) {
        // Si la autenticación biométrica falló, mostrar un mensaje
        if (mounted) {
          showAppSnackBar(
            context,
            context.translate('auth.biometricAuthFailed'),
            const Duration(seconds: 2),
            backgroundColor: AppTheme.getRedColor(context),
          );
        }
        return false;
      }

      if (mounted) {
        // Si la autenticación biométrica fue exitosa, iniciar sesión
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          _isLoading = true;
        });

        // Obtener las credenciales guardadas y hacer login
        final loginSuccess =
            await authProvider.loginWithSavedCredentials(context);

        setState(() {
          _isLoading = false;
        });

        if (!loginSuccess && mounted) {
          // Si el login falló, mostrar un mensaje
          showAppSnackBar(
            context,
            authProvider.errorMessage ?? context.translate('auth.authError'),
            const Duration(seconds: 2),
            backgroundColor: AppTheme.getRedColor(context),
          );
          return false;
        }

        // Verificar si se requiere autenticación de dos factores
        if (loginSuccess && authProvider.requiresTwoFactor && mounted) {
          debugPrint('Login con biométricos requiere 2FA - mostrando popup');

          setState(() {
            _isLoading = false;
          });

          // Mostrar diálogo para ingresar código 2FA
          final twoFactorCode = await TwoFactorDialog.show(context: context);

          // Si el usuario canceló el diálogo, salir
          if (twoFactorCode == null || !mounted) {
            return false;
          }

          // Paso 2: Enviar código 2FA
          setState(() {
            _isLoading = true;
          });

          final step2Success =
              await authProvider.loginStep2(twoFactorCode, context);

          setState(() {
            _isLoading = false;
          });

          if (!step2Success && mounted) {
            // Si el paso 2 falló, mostrar mensaje de error
            showAppSnackBar(
              context,
              authProvider.errorMessage ?? context.translate('auth.authError'),
              const Duration(seconds: 2),
              backgroundColor: AppTheme.getRedColor(context),
            );
            return false;
          }

          // Si el paso 2 fue exitoso, navegar al home
          if (step2Success && mounted) {
            await Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          }

          return step2Success;
        }

        // Si el login fue exitoso y no requiere 2FA, navegar a la pantalla de inicio
        if (loginSuccess && mounted) {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }

        return loginSuccess;
      }

      return false;
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          '${context.translate('auth.error')}: $e',
          const Duration(seconds: 2),
          backgroundColor: AppTheme.getRedColor(context),
        );
      }
      return false;
    }
  }

  /// Muestra un diálogo preguntando al usuario si desea activar la autenticación biométrica
  Future<void> _showBiometricEnableDialog(
    BiometricProvider biometricProvider,
  ) async {
    if (!context.mounted) return;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            context.translateWithArgs(
              'profile.biometricEnableQuestion',
              args: [biometricProvider.biometricType],
            ),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyMedium(context),
            ),
          ),
          content: Text(
            context.translateWithArgs(
              'profile.biometricEnableDescription',
              args: [biometricProvider.biometricType],
            ),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyMedium(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.translate('profile.notNow'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.translate('profile.enable'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Si el usuario acepta activar la biometría
    if (result == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();

      // Intentar habilitar la biometría
      final success = await biometricProvider.toggleBiometric(true);

      if (success && context.mounted) {
        // Guardar las credenciales actuales para uso futuro
        await authProvider.saveCredentials(
          _usernameController.text.toLowerCase(),
          _passwordController.text,
        );

        // Mostrar mensaje de éxito
        if (context.mounted) {
          showAppSnackBar(
            context,
            context.translateWithArgs(
              'profile.biometricEnableSuccess',
              args: [biometricProvider.biometricType],
            ),
            const Duration(seconds: 2),
            backgroundColor: AppTheme.getBlueColor(context),
          );
        }
      } else if (context.mounted) {
        // Mostrar mensaje de error
        showAppSnackBar(
          context,
          context.translateWithArgs(
            'profile.biometricEnableFailed',
            args: [biometricProvider.biometricType],
          ),
          const Duration(seconds: 2),
          backgroundColor: AppTheme.getRedColor(context),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    // final biometricProvider = Provider.of<BiometricProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: _isLoading
            ? LoadingView(message: context.translate('common.loadingGif'))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),
                        Center(
                          child: Image.asset(
                            AppTheme.getFreewayLogoType(context),
                            height: 80,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          context.translate('auth.welcomeBack'),
                          style: TextStyle(
                            fontSize: responsiveFontSizes.titleLarge(context),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTitleTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.translate('auth.signInToAccount'),
                          style: TextStyle(
                            fontSize: responsiveFontSizes.titleMedium(context),
                            color: AppTheme.getTextGreyColor(context),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Campos de login normal
                        SizedBox(
                          width: 346,
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: AppTheme.inputDecoration(
                              context,
                              labelText: context.translate('auth.username'),
                            ),
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodyMedium(context),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            // Convertir automáticamente a minúsculas mientras el usuario escribe
                            onChanged: (value) {
                              if (value != value.toLowerCase()) {
                                _usernameController.value = TextEditingValue(
                                  text: value.toLowerCase(),
                                  selection: _usernameController.selection,
                                );
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context
                                    .translate('auth.pleaseEnterUsername');
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 346,
                          child: TextFormField(
                            controller: _passwordController,
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
                            ),
                            style: TextStyle(
                              fontSize: responsiveFontSizes.bodyMedium(context),
                            ),
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context
                                    .translate('auth.pleaseEnterPassword');
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  AppTheme.getPrimaryColor(context),
                              textStyle: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodySmall(context),
                              ),
                            ),
                            child:
                                Text(context.translate('auth.forgotPassword')),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.getPrimaryColor(context),
                              minimumSize: const Size(346, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              context.translate('auth.loginButton'),
                              style: TextStyle(
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ),
                        if (_isBiometricEnabled)
                          Center(
                            child: Consumer<BiometricProvider>(
                              builder: (context, biometricProvider, child) {
                                return IconButton(
                                  icon: biometricProvider.biometricType ==
                                          'Face ID'
                                      ? Image.asset(
                                          'assets/home/icons/face_id_icon.png',
                                          width: 40,
                                          height: 40,
                                          color:
                                              AppTheme.getPrimaryColor(context),
                                        )
                                      : Icon(
                                          Icons.fingerprint,
                                          color:
                                              AppTheme.getPrimaryColor(context),
                                          size: 40,
                                        ),
                                  onPressed: () async {
                                    if (await _authenticateWithBiometrics()) {
                                      if (context.mounted) {
                                        await Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          '/home',
                                          (route) => false,
                                        );
                                      }
                                    }
                                  },
                                  tooltip:
                                      context.translate('auth.biometricLogin'),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                        Wrap(
                          children: [
                            Text(
                              context.translate('auth.noAccount'),
                              style: TextStyle(
                                color: AppTheme.getTextGreyColor(context),
                                fontSize:
                                    responsiveFontSizes.bodyMedium(context),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    AppTheme.getPrimaryColor(context),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.translate('auth.createAccount'),
                                style: TextStyle(
                                  fontSize:
                                      responsiveFontSizes.bodyMedium(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      bool success;

      // Paso 1: Enviar credenciales
      // Aseguramos que el email siempre se envíe en minúsculas
      final email = _usernameController.text.toLowerCase();
      success = await authProvider.loginStep1(
        email,
        _passwordController.text,
        context,
      );

      // Verificar si se requiere autenticación de dos factores
      if (success && authProvider.requiresTwoFactor) {
        setState(() => _isLoading = false);

        // Mostrar diálogo para ingresar código 2FA
        final twoFactorCode = await TwoFactorDialog.show(context: context);

        // Si el usuario canceló el diálogo, salir
        if (twoFactorCode == null || !mounted) {
          return;
        }

        // Paso 2: Enviar código 2FA
        setState(() => _isLoading = true);
        success = await authProvider.loginStep2(twoFactorCode, context);
      }

      setState(() => _isLoading = false);

      // Si el login fue exitoso y la biometría está disponible y habilitada, guardar las credenciales
      if (success && _isBiometricAvailable && _isBiometricEnabled) {
        // Aseguramos que el email siempre se guarde en minúsculas
        await authProvider.saveCredentials(
          email, // Usamos el email ya convertido a minúsculas
          _passwordController.text,
        );
      }

      if (success && mounted) {
        // Verificar si la biometría está disponible pero no habilitada
        final biometricProvider = context.read<BiometricProvider>();

        // Establecer el contexto para las traducciones
        biometricProvider.setContext(context);

        await biometricProvider.refreshBiometricState();

        // Si la biometría está disponible pero no habilitada, mostrar el diálogo
        if (biometricProvider.isAvailable && !biometricProvider.isEnabled) {
          await _showBiometricEnableDialog(biometricProvider);
        }

        await Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      } else if (mounted) {
        // Verificar si el mensaje de error es una clave de traducción
        String errorMessage;
        if (authProvider.errorMessage != null &&
            authProvider.errorMessage!.startsWith('auth.')) {
          // Si es una clave de traducción, obtener el texto traducido
          errorMessage = context.translate(authProvider.errorMessage!);
        } else {
          // Si no es una clave de traducción, usar el mensaje tal cual o el mensaje de error por defecto
          errorMessage =
              authProvider.errorMessage ?? context.translate('auth.authError');
        }

        showAppSnackBar(
          context,
          errorMessage,
          const Duration(seconds: 2),
          backgroundColor: AppTheme.getRedColor(context),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _twoFactorCodeController.dispose();
    super.dispose();
  }
}
