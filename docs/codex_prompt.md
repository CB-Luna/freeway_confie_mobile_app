# 🤖 Prompt para Codex - Freeway Insurance Web

**Instrucciones:** Copia y pega este prompt en Codex cuando inicies la implementación.

---

## 🎯 Contexto del Proyecto

Estoy creando la versión web de la aplicación móvil Freeway Insurance. Ya tengo:
- Repositorio creado: `freeway_confie_web_app`
- Documentación en `docs/`:
  - `web_setup_guide.md` - Guía paso a paso de setup inicial
  - `web_implementation_plan.md` - Plan detallado de 12 semanas con arquitectura, fases y checklist

## 📋 Tarea Principal

Quiero que implementes la **Fase 1: Preparación y Setup** del plan de implementación siguiendo la guía `web_setup_guide.md`.

## 🏗️ Arquitectura del Proyecto

**Stack Tecnológico:**
- Flutter Web 3.29+
- Riverpod 2.0+ (gestión de estado)
- GoRouter 13.0+ (navegación)
- Dio 5.0+ + Retrofit (HTTP)
- flutter_screenutil (responsive)

**Patrones:**
- Clean Architecture (domain, data, presentation)
- Repository Pattern
- BLoC/StateNotifier con Riverpod

## 🔌 Endpoints y API Keys

**Producción:**
- Auth: `https://confie-customer.azurewebsites.net` (API Key: `TMDpw6vDVv5AJ2vGaMoQybFsZpm57U5BqaYhMGjf5WHYyys82huZYLRb1FN8r5Y6`)
- Office: `https://inquiry.confie.com` (API Key: `0yoZaSdIgj+i+ny4+1TBvw==`)
- Wallet: `https://confie-wallet-api.azurewebsites.net` (API Key: `Hwsed7698FdhskG5lkkg`)

**Desarrollo:**
- Auth: `https://confie-customer-np.azurewebsites.net` (API Key: `jEk40pLbflj4vQ6RyhQmI3JxDAXjUhdWrEjYBgQRAuSs8X6ged161peEtM4mM8sT`)
- Office: `https://stg-inquiry.confie.com` (API Key: `fjzzkOuCefd8-Z86i9HMGWQ=`)
- Wallet: `https://confie-wallet-api-np.azurewebsites.net` (API Key: `GfhGdjdx3rfGBBFkf`)

**Gestión de ambientes:** Usar `String.fromEnvironment` con `--dart-define=env=dev` para desarrollo.

## 📁 Estructura de Carpetas Requerida

```
freeway_confie_web_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── route_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── responsive_theme.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_guard.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── extensions.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── services/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   ├── dashboard/
│   │   ├── policies/
│   │   ├── offices/
│   │   ├── quote/
│   │   ├── contact/
│   │   ├── claims/
│   │   ├── wallet/
│   │   ├── profile/
│   │   └── settings/
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   ├── buttons/
│   │   │   ├── inputs/
│   │   │   └── cards/
│   │   ├── components/
│   │   │   ├── layouts/
│   │   │   └── navigation/
│   │   └── utils/
│   └── main.dart
├── web/
├── test/
├── docs/
└── pubspec.yaml
```

## ✅ Tareas Específicas de Fase 1

Sigue exactamente la guía `web_setup_guide.md`:

1. **Inicializar proyecto Flutter Web**
   - Ejecutar `flutter create --platforms web .`
   - Configurar `pubspec.yaml` con las dependencias especificadas

2. **Crear estructura de carpetas**
   - Crear toda la estructura de carpetas base
   - No crear archivos de features aún, solo la estructura

3. **Configurar constantes**
   - Crear `lib/core/constants/app_constants.dart`
   - Crear `lib/core/constants/api_constants.dart` con TODOS los endpoints y API keys (producción y desarrollo)
   - Crear `lib/core/constants/route_constants.dart`

4. **Configurar pubspec.yaml**
   - Usar las dependencias exactas especificadas en la guía
   - Incluir flutter_riverpod, go_router, dio, retrofit, flutter_screenutil, etc.

5. **Configurar analysis_options.yaml**
   - Usar la configuración especificada en la guía

6. **Configurar router base**
   - Crear `lib/core/router/app_router.dart` con GoRouter
   - Configurar rutas básicas: root, login, dashboard

7. **Configurar tema responsive**
   - Crear `lib/core/theme/app_theme.dart`
   - Implementar tema claro y oscuro con flutter_screenutil

8. **Actualizar main.dart**
   - Configurar ProviderScope de Riverpod
   - Integrar GoRouter
   - Configurar tema responsive

9. **Primer build**
   - Ejecutar `flutter pub get`
   - Ejecutar `flutter build web --dart-define=env=dev`
   - Verificar que no haya errores

## ⚠️ Requisitos Importantes

1. **Usar exactamente los endpoints y API keys** especificados en este prompt
2. **Implementar String.fromEnvironment** para gestión de ambientes
3. **Seguir la estructura de carpetas** exactamente como se especifica
4. **Usar las dependencias exactas** con las versiones especificadas
5. **No crear código de features aún** (auth, dashboard, etc.) - solo el setup base
6. **Asegurar que el build web funcione** antes de continuar

## 🎨 Estilo de Código

- Usar `library;` al inicio de archivos Dart
- Seguir las convenciones de Flutter/Dart
- Usar const constructores cuando sea posible
- Comentar código complejo
- Usar nombres descriptivos en inglés

## 📝 Verificación

Al finalizar, verifica:
- [ ] Estructura de carpetas creada correctamente
- [ ] pubspec.yaml configurado con todas las dependencias
- [ ] Constantes de API configuradas con producción y desarrollo
- [ ] GoRouter configurado con rutas básicas
- [ ] Tema responsive implementado
- [ ] main.dart configurado con Riverpod y GoRouter
- [ ] `flutter pub get` ejecutado sin errores
- [ ] `flutter build web --dart-define=env=dev` exitoso
- [ ] App se abre en Chrome sin errores

## 🚀 Siguiente Paso

Después de completar la Fase 1, proceder a la Fase 2: Autenticación y Dashboard, según el plan `web_implementation_plan.md`.

---

**Nota:** Toda la documentación detallada está en `docs/web_setup_guide.md` y `docs/web_implementation_plan.md`. Referencia esos archivos para cualquier duda durante la implementación.
