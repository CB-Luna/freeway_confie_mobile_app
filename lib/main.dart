import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/add_insurance.dart';
import 'pages/home_page.dart';
import 'pages/location_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/splash_screen.dart';
import 'pages/submit_claim_page.dart';
import 'providers/auth_provider.dart';
import 'providers/biometric_provider.dart';
import 'providers/home_policy_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_restart.dart';

// Clave global para reiniciar la aplicación
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Configurar captura de errores no manejados
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Error no manejado: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Iniciando aplicación Freeway Insurance');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HomePolicyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BiometricProvider>(
          // Crear el BiometricProvider
          create: (_) => BiometricProvider(),
          // Actualizar el BiometricProvider con la referencia al AuthProvider
          update: (_, authProvider, biometricProvider) {
            biometricProvider!.setAuthProvider(authProvider);
            return biometricProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRestart(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Freeway Insurance',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(nextScreen: LoginPage()),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
              '/submit-claim': (context) => const SubmitClaimPage(),
              '/profile': (context) => const ProfilePage(),
              '/add-insurance': (context) => const AddInsurancePage(),
              '/location': (context) => const LocationPage(),
            },
          );
        },
      ),
    );
  }
}
