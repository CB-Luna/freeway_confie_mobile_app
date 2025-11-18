import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freeway_app/data/constants.dart';
import 'package:freeway_app/data/services/auth_service.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Página para cambiar la contraseña del usuario
class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final responsiveFontSizes = ResponsiveFontSizes();

  @override
  void initState() {
    super.initState();
    _setupTextControllerListeners();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setupTextControllerListeners() {
    void listener() {
      final hasCurrentPassword = _currentPasswordController.text.isNotEmpty;
      final hasNewPassword = _newPasswordController.text.isNotEmpty;
      final hasConfirmPassword = _confirmPasswordController.text.isNotEmpty;

      final newHasChanges =
          hasCurrentPassword && hasNewPassword && hasConfirmPassword;

      if (newHasChanges != _hasChanges) {
        setState(() {
          _hasChanges = newHasChanges;
        });
      }
    }

    _currentPasswordController.addListener(listener);
    _newPasswordController.addListener(listener);
    _confirmPasswordController.addListener(listener);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mostrar el indicador de carga
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener el AuthProvider para acceder al usuario actual
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Crear una instancia del servicio de autenticación
      final authService = AuthService(
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

      // Añadir logs para depuración
      debugPrint(
        'Iniciando cambio de contraseña para: ${currentUser.username}',
      );

      // Llamar al método de cambio de contraseña sin mostrar un diálogo adicional
      final success = await authService.changePassword(
        username: currentUser.username,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      debugPrint('Resultado de cambio de contraseña: $success');

      if (!mounted) return;

      if (success) {
        // Actualizar las credenciales guardadas si los biométricos están activados
        if (await authProvider.hasCredentials()) {
          await authProvider.saveCredentials(
            currentUser.username,
            _newPasswordController.text,
          );
          debugPrint('Credenciales actualizadas correctamente');
        }

        if (!mounted) return;

        showAppSnackBar(
          context,
          context.translate('profile.passwordPage.saveSuccess'),
          const Duration(seconds: 2),
          backgroundColor: Colors.green,
        );

        // Cerrar la página después de actualizar la contraseña
        Navigator.pop(context);
      } else {
        // Manejar errores de la API
        showAppSnackBar(
          context,
          context.translate('profile.passwordPage.saveError'),
          const Duration(seconds: 2),
          backgroundColor: AppTheme.getRedColor(context),
        );
      }
    } catch (e) {
      debugPrint('Error en cambio de contraseña: $e');

      if (!mounted) return;

      showAppSnackBar(
        context,
        '${context.translate('profile.passwordPage.saveError')}: $e',
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

  // El método _isPasswordValid ya no es necesario porque las validaciones
  // se realizan directamente en el validator de cada campo TextFormField

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
        title: Text(
          context.translate('profile.passwordPage.title'),
          style: TextStyle(
            color: AppTheme.white,
            fontSize: responsiveFontSizes.titleLarge(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? LoadingView(
              message: context.translate('profile.passwordPage.updating'),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                color: AppTheme.getBackgroundColor(context),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildPasswordForm(context),
                    const SizedBox(height: 24),
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPasswordForm(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('profile.passwordPage.title'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.titleLarge(context),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 16),
              // Campo de contraseña actual
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText:
                      context.translate('profile.passwordPage.currentPassword'),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('validation.required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de nueva contraseña
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText:
                      context.translate('profile.passwordPage.newPassword'),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  // Añadir texto de ayuda para explicar los requisitos de la contraseña
                  helperText: context.translate('auth.passwordRequirements'),
                  helperMaxLines: 4,
                ),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
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
              const SizedBox(height: 16),
              // Campo de confirmación de contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText:
                      context.translate('profile.passwordPage.confirmPassword'),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('validation.required');
                  }
                  if (value != _newPasswordController.text) {
                    return context
                        .translate('profile.passwordPage.passwordMismatch');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.getPrimaryColor(context),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor:
                AppTheme.getPrimaryColor(context).withAlpha(179),
            disabledForegroundColor: Colors.white70,
          ),
          child: Text(
            context.translate('profile.passwordPage.save'),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
