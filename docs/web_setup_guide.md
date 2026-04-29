# 🚀 Guía de Setup Inicial - Freeway Insurance Web

**Versión:** 1.0  
**Fecha:** Abril 2026

---

## 📋 Índice

1. [Requisitos Previos](#requisitos-previos)
2. [Creación del Repositorio en GitHub](#creación-del-repositorio-en-github)
3. [Inicialización del Proyecto Flutter](#inicialización-del-proyecto-flutter)
4. [Configuración de la Estructura](#configuración-de-la-estructura)
5. [Setup de Dependencias](#setup-de-dependencias)
6. [Configuración de Router y Tema](#configuración-de-router-y-tema)
7. [Extracción de Código Compartido](#extracción-de-código-compartido)
8. [Primer Build y Verificación](#primer-build-y-verificación)

---

## 🔧 Requisitos Previos

### Software Necesario

- **Flutter SDK:** 3.29.1 o superior
- **Dart SDK:** 3.7.0 o superior
- **Git:** 2.30.0 o superior
- **VS Code** o **Android Studio** (recomendado)
- **Chrome** (para testing web)

### Extensiones de VS Code (Recomendadas)

- Flutter
- Dart
- Riverpod Snippets
- Flutter Widget Snippets
- GitLens
- Prettier

---

## 📦 Creación del Repositorio en GitHub

### Paso 1: Crear el Repositorio

1. Inicia sesión en [GitHub](https://github.com)
2. Haz clic en **"+"** → **"New repository"**
3. Configura:

   ```
   Repository name: freeway-web
   Description: Freeway Insurance Web Application
   Visibility: Private
   Initialize with:
     ☐ Add a README file
     ☐ Add .gitignore (Flutter)
     ☐ Choose a license (MIT)
   ```

4. Haz clic en **"Create repository"**

### Paso 2: Clonar el Repositorio

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/freeway-web.git
cd freeway-web
```

---

## 🎯 Inicialización del Proyecto Flutter

### Paso 1: Crear Proyecto Flutter Web

```bash
# Desde el directorio del repositorio
flutter create --platforms web .
```

Esto creará la estructura base del proyecto Flutter para web.

### Paso 2: Configurar pubspec.yaml

Reemplaza el contenido de `pubspec.yaml` con:

```yaml
name: freeway_web
description: Freeway Insurance Web Application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.6 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Navigation
  go_router: ^13.0.0
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
  
  # Responsive
  flutter_screenutil: ^5.9.0
  
  # Maps
  google_maps_flutter: ^2.10.1
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # UI Components
  flutter_svg: ^2.0.9
  lottie: ^3.0.0
  flutter_spinkit: ^5.2.1
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1
  url_launcher: ^6.3.1
  webview_flutter: ^4.7.0
  
  # Icons
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
  retrofit_generator: ^7.0.8

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  
  fonts:
    - family: Open Sans
      fonts:
        - asset: assets/fonts/OpenSans-Regular.ttf
        - asset: assets/fonts/OpenSans-Bold.ttf
          weight: 700
```

### Paso 3: Instalar Dependencias

```bash
flutter pub get
```

---

## 📁 Configuración de la Estructura

### Paso 1: Crear Estructura de Carpetas

```bash
# Crear estructura base
mkdir -p lib/core/{constants,theme,router,utils}
mkdir -p lib/features/{auth,dashboard,policies,offices,quote,contact,claims,wallet,profile,settings}/{data/{models,repositories,services},domain/{entities,usecases},presentation/{providers,pages,widgets}}
mkdir -p lib/shared/{widgets/{common,buttons,inputs,cards},components/{layouts,navigation},utils}
mkdir -p assets/{images,icons,animations,fonts}
mkdir -p test/{unit,widget,integration}
mkdir -p docs/{architecture,api,deployment}
mkdir -p scripts
```

### Paso 2: Crear Archivos de Constantes

**lib/core/constants/app_constants.dart**

```dart
library;

class AppConstants {
  static const String appName = 'Freeway Insurance';
  static const String appVersion = '1.0.0';
  
  // Screen sizes
  static const double mobileWidth = 600;
  static const double tabletWidth = 1200;
  static const double desktopWidth = 1920;
}
```

**lib/core/constants/api_constants.dart**

```dart
library;

/// <<<<<<<< Embebed Forms Web >>>>>>>>>
const String urlBaseEmbed = 'https://www.freeway.com/';
const String urlBaseEmbedBuyProduct = 'https://buy.freeway.com/app/';
const String urlBaseEmbedCarRegistration = 'https://www.carregistration.com/';
const String urlBaseEmbedTriton = 'https://triton.freeway.com/';
const String urlBaseEmbedTaxmax = 'https://www.taxmax.com/';
const String urlBaseEmbedRate = 'https://rate.freeway.com/';
const String urlBaseEmbedQuote = 'https://quote.sanborns.com/';
const String urlBaseEmbedSeguros = 'https://www.freeway.com/';
const String urlBaseEmbedQuickPay = 'https://quickpay.freeway.com/';

/// <<<<<<<< Login & Registration >>>>>>>>>

// Producción
const String envLoginProd = 'https://confie-customer.azurewebsites.net';
const String apiKeyLoginProd = 'TMDpw6vDVv5AJ2vGaMoQybFsZpm57U5BqaYhMGjf5WHYyys82huZYLRb1FN8r5Y6';

// Desarrollo
const String envLoginDev = 'https://confie-customer-np.azurewebsites.net';
const String apiKeyLoginDev = 'jEk40pLbflj4vQ6RyhQmI3JxDAXjUhdWrEjYBgQRAuSs8X6ged161peEtM4mM8sT';

const String envLogin = String.fromEnvironment(
  'env',
  defaultValue: envLoginProd,
);

const String apiKeyLogin = String.fromEnvironment(
  'env',
  defaultValue: apiKeyLoginProd,
) == 'dev' ? apiKeyLoginDev : apiKeyLoginProd;

/// <<<<<<<< PK Pass Wallet (Google / Apple) >>>>>>>>>

// Producción
const String envWalletProd = 'https://confie-wallet-api.azurewebsites.net';
const String apiKeyWalletProd = 'Hwsed7698FdhskG5lkkg';

// Desarrollo
const String envWalletDev = 'https://confie-wallet-api-np.azurewebsites.net';
const String apiKeyWalletDev = 'GfhGdjdx3rfGBBFkf';

const String envWallet = String.fromEnvironment(
  'env',
  defaultValue: envWalletProd,
);

const String apiKeyWallet = String.fromEnvironment(
  'env',
  defaultValue: apiKeyWalletProd,
) == 'dev' ? apiKeyWalletDev : apiKeyWalletProd;

/// <<<<<<<< Office Locations >>>>>>>>>

// Producción
const String envOfficeProd = 'https://inquiry.confie.com';
const String apiKeyOfficeProd = '0yoZaSdIgj+i+ny4+1TBvw==';

// Desarrollo
const String envOfficeDev = 'https://stg-inquiry.confie.com';
const String apiKeyOfficeDev = 'fjzzkOuCefd8-Z86i9HMGWQ=';

const String envOffice = String.fromEnvironment(
  'env',
  defaultValue: envOfficeProd,
);

const String apiKeyOffice = String.fromEnvironment(
  'env',
  defaultValue: apiKeyOfficeProd,
) == 'dev' ? apiKeyOfficeDev : apiKeyOfficeProd;

/// <<<<<<<< Thirds Party >>>>>>>>>

const String envThirdsPartyZipcode = 'https://api.zippopotam.us/us/';
const String envThirdsPartyAppleMap = 'https://maps.apple.com/';
const String envThirdsPartyGoogleMap = 'https://www.google.com/maps/';
```

**lib/core/constants/route_constants.dart**

```dart
library;

class RouteConstants {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String policies = '/policies';
  static const String offices = '/offices';
  static const String quote = '/quote';
  static const String contact = '/contact';
  static const String claims = '/claims';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
```

---

## 🎨 Setup de Dependencias

### Paso 1: Configurar Analysis Options

Crea `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_single_quotes
```

### Paso 2: Configurar .gitignore

Actualiza `.gitignore`:

```
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release
```

---

## 🧭 Configuración de Router y Tema

### Paso 1: Configurar GoRouter

**lib/core/router/app_router.dart**

```dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freeway_web/core/constants/route_constants.dart';
import 'package:freeway_web/features/auth/presentation/pages/login_page.dart';
import 'package:freeway_web/features/dashboard/presentation/pages/dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: RouteConstants.root,
  routes: [
    GoRoute(
      path: RouteConstants.root,
      redirect: (context, state) {
        // TODO: Check auth status
        return RouteConstants.login;
      },
    ),
    GoRoute(
      path: RouteConstants.login,
      pageBuilder: (context, state) => const MaterialPage(
        child: LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.dashboard,
      pageBuilder: (context, state) => const MaterialPage(
        child: DashboardPage(),
      ),
    ),
  ],
);
```

### Paso 2: Configurar Tema Responsive

**lib/core/theme/app_theme.dart**

```dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0066CC),
        brightness: Brightness.light,
      ),
      fontFamily: 'Open Sans',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16.sp),
        bodyMedium: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0066CC),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Open Sans',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16.sp),
        bodyMedium: TextStyle(fontSize: 14.sp),
      ),
    );
  }
}
```

---

## 🔄 Extracción de Código Compartido

### Paso 1: Copiar Servicios del Proyecto Mobile

Desde el proyecto `freeway_confie_mobile_app`, copia:

```bash
# Desde freeway_confie_mobile_app/lib/data/services/
cp AuthService.dart freeway-web/lib/features/auth/data/services/
cp OfficeService.dart freeway-web/lib/features/offices/data/services/
cp GoogleWalletService.dart freeway-web/lib/features/wallet/data/services/
cp AppleWalletService.dart freeway-web/lib/features/wallet/data/services/
cp LocationService.dart freeway-web/lib/shared/utils/
```

### Paso 2: Copiar Modelos

```bash
# Desde freeway_confie_mobile_app/lib/data/models/
cp auth/ freeway-web/lib/features/auth/data/models/
cp policy/ freeway-web/lib/features/dashboard/data/models/
```

### Paso 3: Adaptar para Web

- Reemplazar `flutter_secure_storage` con `shared_preferences` para datos no sensibles
- Mantener `flutter_secure_storage` para tokens y credenciales
- Adaptar llamadas nativas (biometría) para WebAuthn

---

## 🚀 Primer Build y Verificación

### Paso 1: Build de Desarrollo

```bash
# Build para desarrollo
flutter build web --dart-define=env=dev
```

### Paso 2: Ejecutar en Local

```bash
# Ejecutar en modo desarrollo
flutter run -d chrome --dart-define=env=dev
```

### Paso 3: Verificar

- [ ] La app se abre en Chrome
- [ ] No hay errores en consola
- [ ] El router funciona
- [ ] El tema se aplica correctamente
- [ ] Las constantes de API se cargan correctamente

---

## 📝 Próximos Pasos

1. Implementar el layout base con sidemenu
2. Implementar el sistema de autenticación
3. Seguir el plan de implementación detallado en `web_implementation_plan.md`

---

**Última actualización:** Abril 2026  
**Mantenido por:** Equipo de Desarrollo Freeway Insurance
