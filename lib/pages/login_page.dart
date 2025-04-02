import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/biometric_provider.dart';
import '../widgets/theme/app_theme.dart';
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
  final _twoFactorCodeController = TextEditingController(); // Se mantiene para uso futuro
  bool _isLoading = false;
  bool _obscureText = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _showTwoFactorInput = false; // Se mantiene para uso futuro pero siempre será falso

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
    setState(() {
      _isBiometricAvailable = biometricProvider.isAvailable;
      _isBiometricEnabled = biometricProvider.isEnabled;
    });

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
      final success = await biometricProvider.authenticate();

      if (!success) {
        // Si la autenticación biométrica falló, mostrar un mensaje
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed with biometrics.'),
              backgroundColor: Colors.red,
            ),
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
        final loginSuccess = await authProvider.loginWithSavedCredentials();

        setState(() {
          _isLoading = false;
        });

        if (!loginSuccess && mounted) {
          // Si el login falló, mostrar un mensaje
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to login.'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }

        return loginSuccess;
      }

      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final biometricProvider = Provider.of<BiometricProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const LoadingView()
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
                            'assets/auth/freeway_logo.png',
                            height: 80,
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to your account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Campos de login normal
                        SizedBox(
                          height: 60,
                          width: 346,
                          child: TextFormField(
                            controller: _usernameController,
                            decoration:
                                AppTheme.inputDecoration(labelText: 'Username'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
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
                            decoration:
                                AppTheme.inputDecoration(labelText: 'Password')
                                    .copyWith(
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
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              minimumSize: const Size(346, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_isBiometricAvailable)
                          Center(
                            child: Consumer<BiometricProvider>(
                              builder: (context, biometricProvider, child) {
                                return IconButton(
                                  icon: Icon(
                                    biometricProvider.biometricType ==
                                            'Face ID'
                                        ? Icons.face
                                        : Icons.fingerprint,
                                    color: AppTheme.primaryColor,
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    if (await _authenticateWithBiometrics())
                                      if (mounted) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          '/home',
                                          (route) => false,
                                        );
                                      }
                                  },
                                  tooltip:
                                      'Acceder con ${biometricProvider.biometricType}',
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
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
                                foregroundColor: AppTheme.primaryColor,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 14,
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

      // Actualmente solo usamos loginStep1 ya que el 2FA está desactivado
      // pero mantenemos la estructura para uso futuro
      success = await authProvider.loginStep1(
        _usernameController.text,
        _passwordController.text,
      );

      // Esta condición nunca se cumplirá mientras el 2FA esté desactivado
      // Se mantiene para uso futuro
      if (success && authProvider.requiresTwoFactor) {
        // Código comentado para uso futuro cuando se reactive el 2FA
        /*
        setState(() {
          _showTwoFactorInput = true;
          _isLoading = false;
        });
        return; // Detener el proceso para esperar el código 2FA
        */
      }

      // Si el login fue exitoso y la biometría está disponible y habilitada, guardar las credenciales
      if (success && _isBiometricAvailable && _isBiometricEnabled) {
        await authProvider.saveCredentials(
          _usernameController.text,
          _passwordController.text,
        );
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        await Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      } else if (mounted) {
        final errorMessage =
            authProvider.errorMessage ?? 'Authentication error.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
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
