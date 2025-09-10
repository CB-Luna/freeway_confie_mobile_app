import 'package:flutter/material.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';

class HeaderSection extends StatefulWidget {
  final VoidCallback? onNotificationTap;

  const HeaderSection({
    super.key,
    this.onNotificationTap,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  // Método para construir un avatar con las iniciales del usuario
  Widget _buildInitialsAvatar(String fullName, {required double size}) {
    // Obtener las iniciales del nombre completo
    final initials = _getInitials(fullName);

    // Generar un color basado en el nombre (para que sea consistente para el mismo usuario)
    final color = _getAvatarColor(fullName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsiveFontSizes.avatarIcon(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Método para obtener las iniciales del nombre
  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    final nameParts = fullName.trim().split(' ');
    if (nameParts.length >= 2) {
      // Si hay al menos dos partes en el nombre, tomar la primera letra de cada una
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      // Si solo hay una parte, tomar la primera letra
      return nameParts[0][0].toUpperCase();
    }

    return '';
  }

  // Método para generar un color basado en el nombre
  Color _getAvatarColor(String fullName) {
    if (fullName.isEmpty) return Colors.blue;

    // Usar la suma de los códigos ASCII de los caracteres para generar un número
    final int hashCode =
        fullName.codeUnits.fold(0, (prev, element) => prev + element);

    // Lista de colores para los avatares
    final colors = [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
      Colors.pink[700]!,
      Colors.indigo[700]!,
    ];

    // Seleccionar un color basado en el hash del nombre
    return colors[hashCode % colors.length];
  }

  String _userName = 'Freeway User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedName = await authProvider.getFullName();

    if (mounted) {
      setState(() {
        _userName =
            savedName ?? (authProvider.currentUser?.fullName ?? 'Freeway User');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notificationCount = notificationProvider.notificationCount;

    debugPrint('HeaderSection - Número de notificaciones: $notificationCount');

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getBoxShadowColor(context),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo con GestureDetector para navegar a login
          GestureDetector(
            onTap: () {
              debugPrint('HeaderSection - Clic en logo de Freeway');
              // Limpiar estado de autenticación
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();

              // Navegar a la pantalla de login
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Image.asset(
              AppTheme.getFreewayLogoType(context),
              height: 32,
            ),
          ),
          // Right side icons
          Row(
            children: [
              // Notifications
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Icono de notificación con animación Rive
                  // Usamos Material para asegurar el efecto de splash y mejor feedback táctil
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        debugPrint(
                          'HeaderSection - Clic en icono de notificaciones',
                        );
                        // Llamar a la función de navegación si está disponible
                        if (widget.onNotificationTap != null) {
                          widget.onNotificationTap!();
                        } else {
                          // Si no hay función de navegación, mostrar un mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('$notificationCount notificaciones'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: notificationCount > 0
                              // Usar el icono animado de Rive cuando hay notificaciones
                              ? RiveAnimatedIcon(
                                  riveIcon: RiveIcon.bell,
                                  loopAnimation: true,
                                  width: 24,
                                  height: 24,
                                  strokeWidth: 4,
                                  color: AppTheme.getIconColor(context),
                                )
                              // Usar un espacio reservado cuando no hay notificaciones
                              : Container(),
                        ),
                      ),
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.getRedColor(context),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationCount > 99
                              ? '99+'
                              : notificationCount.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: responsiveFontSizes.avatarIcon(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Avatar
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                child: ClipOval(
                  // Mostrar indicador de carga mientras se obtiene el nombre
                  child: _isLoading
                      ? const SizedBox(
                          width: 33,
                          height: 33,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : authProvider.currentUser?.avatar != null
                          ? Image.network(
                              authProvider.currentUser!.avatar!,
                              width: 33,
                              height: 33,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Si hay un error al cargar la imagen, mostrar las iniciales
                                return _buildInitialsAvatar(
                                  _userName,
                                  size: 33,
                                );
                              },
                            )
                          : _buildInitialsAvatar(
                              _userName,
                              size: 33,
                            ),
                ),
              ),
              // Theme toggle
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getBrightnessColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 24,
                    color: themeProvider.isDarkMode
                        ? Colors.yellow[600]
                        : Colors.blue[900],
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
