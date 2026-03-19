import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeway_app/locatordevice/presentation/pages/location_details_view.dart';
import 'package:provider/provider.dart';

import 'pages/add_insurance.dart';
import 'pages/auth_splash_screen.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/submit_claim_page.dart';
import 'providers/auth_provider.dart';
import 'providers/biometric_provider.dart';
import 'providers/home_policy_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_localizations.dart';
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

  // Bloquear orientación a Portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar modo inmersivo para Android (ocultar controles de navegación del sistema)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  // Configurar color transparente para la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  debugPrint('Iniciando aplicación Freeway Insurance');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HomePolicyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Freeway Insurance',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.currentLocale,
            supportedLocales: languageProvider.supportedLocales,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthSplashScreen(),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
              '/submit-claim': (context) => const SubmitClaimPage(),
              '/profile': (context) => const ProfilePage(),
              '/add-insurance': (context) => const AddInsurancePage(),
              '/location': (context) => const LocationDetailsView(),
            },
          );
        },
      ),
    );
  }
}
