import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Utilidad para reiniciar la aplicación
class AppRestart extends StatefulWidget {
  final Widget child;

  const AppRestart({
    required this.child, super.key,
  });

  /// Reinicia la aplicación
  static void restart(BuildContext context) {
    final state = context.findAncestorStateOfType<AppRestartState>();
    state?.restart();
  }

  @override
  AppRestartState createState() => AppRestartState();
}

class AppRestartState extends State<AppRestart> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

/// Utilidad para cerrar sesión
class AppLogout {
  /// Cierra sesión y navega a la pantalla de login
  static void logoutAndRestart(BuildContext context) {
    try {
      debugPrint('AppLogout: iniciando proceso de logout');
      
      // Obtener el provider y usar el método mejorado
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.performLogout(context);
      
      debugPrint('AppLogout: proceso de logout completado');
    } catch (e) {
      debugPrint('Error durante el logout desde AppLogout: $e');
      
      // Plan de respaldo - intentar navegación directa
      try {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (navError) {
        debugPrint('Error incluso durante navegación de respaldo: $navError');
        
        // Último recurso
        try {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } catch (_) {}
      }
    }
  }
}
