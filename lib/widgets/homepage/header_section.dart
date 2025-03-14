import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';

class HeaderSection extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const HeaderSection({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notificationCount = notificationProvider.notificationCount;

    debugPrint('HeaderSection - Número de notificaciones: $notificationCount');

    return Container(
      width: double.infinity,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 2),
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
              'assets/auth/freeway_logo.png',
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
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      size: 28,
                    ),
                    onPressed: () {
                      debugPrint(
                        'HeaderSection - Clic en icono de notificaciones',
                      );
                      // Llamar a la función de navegación si está disponible
                      if (onNotificationTap != null) {
                        onNotificationTap!();
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
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
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
                            color: Colors.white,
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
                  child: Image.asset(
                    'assets/home/icons/human_avatar.png',
                    width: 33,
                    height: 33,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Theme toggle
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.blue.withAlpha(51)
                      : Colors.grey.withAlpha(26),
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
