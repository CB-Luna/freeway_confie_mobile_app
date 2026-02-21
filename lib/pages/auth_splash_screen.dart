import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _loadAuthSplashScreen();
  }

  Future<void> _loadAuthSplashScreen() async {
    try {
      // Iniciar la animación inmediatamente
      await _controller.forward();

      // Precarga las imágenes en segundo plano
      await Future.wait([
        _preloadImage('assets/splash/Welcome Screen.png'),
      ]);

      // Verificar el estado de autenticación
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = await authProvider.checkAuthStatus();

      if (mounted) {
        // Esperar a que termine la animación si aún no ha terminado
        if (!_controller.isCompleted) {
          await _controller.forward(from: _controller.value);
        }

        // Navegar a la pantalla apropiada
        _navigateToNextScreen(isAuthenticated);
      }
    } catch (e) {
      debugPrint('Failed to load auth splash screen: $e');
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  Future<void> _preloadImage(String assetPath) async {
    try {
      final ImageProvider provider = AssetImage(assetPath);
      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      final Completer<void> completer = Completer<void>();

      final ImageStreamListener listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete();
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          completer.completeError(exception);
        },
      );

      stream.addListener(listener);
      try {
        await completer.future;
      } finally {
        stream.removeListener(listener);
      }
    } catch (e) {
      debugPrint('Failed to preload image $assetPath: $e');
      rethrow;
    }
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    final Widget nextScreen =
        isAuthenticated ? const HomePage() : const LoginPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsiveFontSizes = ResponsiveFontSizes();

    if (_isError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.getRedColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                context.translate('auth.splashScreen.error'),
                style: TextStyle(
                  fontSize: responsiveFontSizes.titleLarge(context),
                  color: AppTheme.getRedColor(context),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isError = false;
                  });
                  _loadAuthSplashScreen();
                },
                child: Text(context.translate('auth.splashScreen.retry')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _animation1,
            child: Image.asset(
              'assets/splash/Welcome Screen.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
