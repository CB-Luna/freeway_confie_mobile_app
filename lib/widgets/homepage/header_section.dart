import 'package:flutter/material.dart';
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
                  GestureDetector(
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
                            content: Text('$notificationCount notificaciones'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: notificationCount > 0
                          // Usar el icono animado de Rive cuando hay notificaciones
                          ? RiveAnimatedIcon(
                              riveIcon: RiveIcon.bell,
                              loopAnimation: true,
                              width: 20,
                              height: 20,
                              strokeWidth: 4,
                              color: AppTheme.getPrimaryColor(context),
                            )
                          // Usar un icono estático cuando no hay notificaciones
                          : Icon(
                              Icons.notifications_outlined,
                              size: 28,
                              color: AppTheme.getPrimaryColor(context),
                            ),
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
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
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 10,
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
                  child: authProvider.currentUser?.avatar != null
                      ? Image.network(
                          authProvider.currentUser!.avatar!,
                          width: 33,
                          height: 33,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Si hay un error al cargar la imagen, mostrar la imagen por defecto
                            return Image.asset(
                              'assets/home/icons/human_avatar.png',
                              width: 33,
                              height: 33,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/home/icons/human_avatar.png',
                          width: 33,
                          height: 33,
                          fit: BoxFit.cover,
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
