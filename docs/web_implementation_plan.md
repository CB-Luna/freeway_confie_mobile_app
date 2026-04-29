# 🚀 Plan de Implementación - Freeway Insurance Web

**Versión:** 1.0  
**Fecha:** Abril 2026  
**Duración estimada:** 12 semanas

---

## 📋 Índice

1. [Visión General](#visión-general)
2. [Arquitectura Técnica](#arquitectura-técnica)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Fases de Implementación](#fases-de-implementación)
5. [Checklist por Fase](#checklist-por-fase)
6. [Decisiones Técnicas](#decisiones-técnicas)
7. [Riesgos y Mitigación](#riesgos-y-mitigación)

---

## 🎯 Visión General

### Objetivo

Crear una aplicación web responsive de Freeway Insurance que complemente la app móvil, permitiendo a los usuarios gestionar sus pólizas, cotizar seguros y acceder a servicios desde cualquier dispositivo con navegador.

### Alcance

- **MVP (Minimum Viable Product):** Dashboard, Pólizas, Oficinas, Cotizar, Contacto, Perfil
- **Fase 2:** Siniestros, Wallet, Configuración avanzada
- **Fase 3:** Chat en vivo, Analytics, Integraciones adicionales

### Plataformas

- **Desktop:** Chrome, Firefox, Safari, Edge
- **Tablet:** iPad, Android tablets
- **Mobile Web:** Responsive design para smartphones

---

## 🏗️ Arquitectura Técnica

### Stack Tecnológico

| Capa              | Tecnología                      | Justificación                                       |
| ----------------- | ------------------------------- | --------------------------------------------------- |
| **Framework**     | Flutter Web 3.29+               | Código compartido con mobile, performance excelente |
| **Estado**        | Riverpod 2.0+                   | Más escalable que Provider, mejor para web          |
| **Navegación**    | GoRouter 13.0+                  | Deep linking, clean URLs, mejor para web            |
| **HTTP**          | Dio 5.0+ + Retrofit             | Mismo stack que mobile, consistencia                |
| **UI Responsive** | flutter_screenutil              | Adaptación automática a diferentes tamaños          |
| **Mapas**         | google_maps_flutter_web         | Mapas interactivos en web                           |
| **Testing**       | flutter_test + integration_test | Tests unitarios y de integración                    |
| **Deploy**        | Firebase Hosting / Vercel       | Hosting rápido, HTTPS automático, CDN               |

### Patrones de Diseño

- **Clean Architecture:** Separación de capas (domain, data, presentation)
- **Repository Pattern:** Abstracción de fuentes de datos
- **BLoC/StateNotifier:** Gestión de estado con Riverpod
- **Factory Pattern:** Creación de widgets y componentes
- **Singleton Pattern:** Servicios globales

### Integraciones

| Servicio       | Uso                           | Producción                            | Desarrollo                               |
| -------------- | ----------------------------- | ------------------------------------- | ---------------------------------------- |
| Auth Backend   | Autenticación, perfil         | `confie-customer.azurewebsites.net`   | `confie-customer-np.azurewebsites.net`   |
| Office Locator | Búsqueda de oficinas          | `inquiry.confie.com`                  | `stg-inquiry.confie.com`                 |
| Wallet API     | Generación de pases digitales | `confie-wallet-api.azurewebsites.net` | `confie-wallet-api-np.azurewebsites.net` |
| Google Maps    | Mapas y rutas                 | `google.com/maps`                     | `google.com/maps`                        |
| Web Embeds     | Cotizadores externos          | freeway.com, buy.freeway.com, etc.    | freeway.com, buy.freeway.com, etc.       |
| ZIP Lookup     | Validación de ZIP             | `api.zippopotam.us`                   | `api.zippopotam.us`                      |

### API Keys

**Producción:**

- Auth API Key: `TMDpw6vDVv5AJ2vGaMoQybFsZpm57U5BqaYhMGjf5WHYyys82huZYLRb1FN8r5Y6`
- Wallet API Key: `Hwsed7698FdhskG5lkkg`
- Office API Key: `0yoZaSdIgj+i+ny4+1TBvw==`

**Desarrollo:**

- Auth API Key: `jEk40pLbflj4vQ6RyhQmI3JxDAXjUhdWrEjYBgQRAuSs8X6ged161peEtM4mM8sT`
- Wallet API Key: `GfhGdjdx3rfGBBFkf`
- Office API Key: `fjzzkOuCefd8-Z86i9HMGWQ=`

### Gestión de Ambientes

Para la versión web, se usará `String.fromEnvironment` para cambiar entre ambientes:

```dart
// Ejemplo en lib/core/constants/api_constants.dart
const String envLogin = String.fromEnvironment(
  'env',
  defaultValue: 'https://confie-customer.azurewebsites.net', // Producción por defecto
);

// Para desarrollo:
// flutter run --dart-define=env=dev
// flutter build web --dart-define=env=dev
```

**Configuración de ambientes:**

- **Producción:** Sin parámetros (usa defaultValue)
- **Desarrollo:** `--dart-define=env=dev`
- **Staging:** `--dart-define=env=staging`

---

## 📁 Estructura del Proyecto

```
freeway-web/
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
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   ├── login_response.dart
│   │   │   │   │   └── policy_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── services/
│   │   │   │       └── auth_service.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── logout_usecase.dart
│   │   │   │       └── register_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── register_page.dart
│   │   │       │   └── forgot_password_page.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── register_form.dart
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── dashboard_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── dashboard_page.dart
│   │   │       └── widgets/
│   │   │           ├── policy_card.dart
│   │   │           ├── quick_action_card.dart
│   │   │           └── notification_panel.dart
│   │   ├── policies/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── policies_page.dart
│   │   │       └── widgets/
│   │   │           ├── policy_grid.dart
│   │   │           ├── policy_filters.dart
│   │   │           └── policy_details_card.dart
│   │   ├── offices/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── offices_page.dart
│   │   │       └── widgets/
│   │   │           ├── office_map.dart
│   │   │           ├── office_list.dart
│   │   │           └── office_details_panel.dart
│   │   ├── quote/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── quote_page.dart
│   │   │       └── widgets/
│   │   │           ├── product_grid.dart
│   │   │           ├── category_tabs.dart
│   │   │           └── quote_webview.dart
│   │   ├── contact/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── contact_page.dart
│   │   │       └── widgets/
│   │   │           ├── contact_form.dart
│   │   │           └── call_center_info.dart
│   │   ├── claims/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── claims_page.dart
│   │   │       └── widgets/
│   │   │           ├── claim_form.dart
│   │   │           └── claim_status_tracker.dart
│   │   ├── wallet/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── wallet_page.dart
│   │   │       └── widgets/
│   │   │           ├── wallet_card.dart
│   │   │           └── wallet_download_button.dart
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   └── profile_page.dart
│   │   │       └── widgets/
│   │   │           ├── profile_form.dart
│   │   │           └── security_settings.dart
│   │   └── settings/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── providers/
│   │           ├── pages/
│   │           │   └── settings_page.dart
│   │           └── widgets/
│   │               ├── theme_selector.dart
│   │               ├── language_selector.dart
│   │               └── notification_settings.dart
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── app_scaffold.dart
│   │   │   │   ├── app_sidemenu.dart
│   │   │   │   ├── app_header.dart
│   │   │   │   ├── loading_widget.dart
│   │   │   │   ├── error_widget.dart
│   │   │   │   └── empty_state_widget.dart
│   │   │   ├── buttons/
│   │   │   │   ├── primary_button.dart
│   │   │   │   ├── secondary_button.dart
│   │   │   │   └── icon_button.dart
│   │   │   ├── inputs/
│   │   │   │   ├── text_field.dart
│   │   │   │   ├── dropdown_field.dart
│   │   │   │   └── search_field.dart
│   │   │   └── cards/
│   │   │       ├── base_card.dart
│   │   │       └── info_card.dart
│   │   ├── components/
│   │   │   ├── layouts/
│   │   │   │   ├── responsive_layout.dart
│   │   │   │   ├── grid_layout.dart
│   │   │   │   └── panel_layout.dart
│   │   │   └── navigation/
│   │   │       ├── breadcrumb.dart
│   │   │       └── tab_bar.dart
│   │   └── utils/
│   │       ├── responsive_helper.dart
│   │       ├── screen_size.dart
│   │       └── break_points.dart
│   └── main.dart
├── web/
│   ├── index.html
│   ├── favicon.png
│   ├── manifest.json
│   └── icons/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── docs/
│   ├── architecture/
│   ├── api/
│   └── deployment/
├── scripts/
│   ├── setup.sh
│   └── build.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── .gitignore
```

---

## 📅 Fases de Implementación

### Fase 1: Preparación y Setup (Semana 1-2)

**Objetivo:** Configurar el proyecto base y extraer código compartido.

#### Tareas:

1. **Creación del Repositorio**
   - Crear repo en GitHub: `freeway-web`
   - Configurar branches: `main`, `develop`, `feature/*`
   - Configurar protections y rules

2. **Setup del Proyecto Flutter**
   - Inicializar proyecto Flutter Web
   - Configurar `pubspec.yaml` con dependencias
   - Configurar `analysis_options.yaml`
   - Setup de linters y formatters

3. **Estructura de Carpetas**
   - Crear estructura de carpetas base
   - Configurar archivos de constantes
   - Setup de tema responsive

4. **Código Compartido**
   - Extraer servicios del proyecto mobile
   - Extraer modelos de datos
   - Crear paquete compartido (opcional)
   - Configurar dependencias

5. **Configuración de Router**
   - Setup de GoRouter
   - Definir rutas base
   - Configurar guards de autenticación

6. **Layout Base**
   - Implementar AppScaffold con sidemenu
   - Implementar AppHeader responsive
   - Implementar AppSidemenu colapsable
   - Configurar breakpoints responsive

**Entregables:**

- ✅ Repositorio creado y configurado
- ✅ Estructura de carpetas completa
- ✅ Layout base funcional
- ✅ Router configurado
- ✅ Código compartido integrado

---

### Fase 2: Autenticación y Dashboard (Semana 3-4)

**Objetivo:** Implementar sistema de autenticación y dashboard inicial.

#### Tareas:

1. **Autenticación**
   - Migrar AuthService del mobile
   - Implementar AuthProvider con Riverpod
   - Crear LoginPage responsive
   - Crear RegisterPage responsive
   - Crear ForgotPasswordPage
   - Implementar 2FA
   - Implementar biometría (WebAuthn)

2. **Dashboard**
   - Implementar DashboardProvider
   - Crear DashboardPage con layout grid
   - Implementar Hero Section con póliza principal
   - Implementar Quick Actions grid
   - Implementar Pólizas Activas grid
   - Implementar Notification Panel

3. **Persistencia**
   - Configurar localStorage para sesión
   - Implementar refresh token
   - Configurar cookies para remember me

**Entregables:**

- ✅ Sistema de autenticación funcional
- ✅ Login/Register/Forgot password
- ✅ Dashboard con pólizas
- ✅ Quick actions funcionales
- ✅ Persistencia de sesión

---

### Fase 3: Pólizas y Oficinas (Semana 5-6)

**Objetivo:** Implementar gestión de pólizas y localizador de oficinas.

#### Tareas:

1. **Mis Pólizas**
   - Implementar PoliciesProvider
   - Crear PoliciesPage con layout responsive
   - Implementar filtros avanzados
   - Implementar búsqueda
   - Implementar vista de lista vs grid
   - Implementar exportar a PDF
   - Implementar comparar pólizas

2. **Oficinas**
   - Migrar OfficeService del mobile
   - Implementar OfficesProvider
   - Crear OfficesPage con layout split
   - Implementar mapa grande con Google Maps
   - Implementar lista lateral de oficinas
   - Implementar búsqueda por ZIP
   - Implementar filtros por servicios
   - Integrar con Google Maps para rutas

**Entregables:**

- ✅ Pólizas con filtros y búsqueda
- ✅ Vista de lista y grid
- ✅ Exportar a PDF
- ✅ Localizador de oficinas funcional
- ✅ Mapa interactivo
- ✅ Rutas a oficinas

---

### Fase 4: Cotización y Contacto (Semana 7-8)

**Objetivo:** Implementar hub de cotización y centro de contacto.

#### Tareas:

1. **Cotizar Seguros**
   - Implementar QuoteProvider
   - Crear QuotePage con tabs
   - Implementar VehicleInsuranceGrid
   - Implementar PropertyInsuranceGrid
   - Implementar PersonalProtectionGrid
   - Implementar BusinessInsuranceGrid
   - Implementar AdditionalProductsGrid
   - Integrar web embeds con prellenado
   - Implementar guardar cotizaciones
   - Implementar compartir cotización

2. **Contacto**
   - Implementar ContactProvider
   - Crear ContactPage con layout split
   - Implementar formulario de contacto
   - Implementar información de call center
   - Implementar chat en vivo (placeholder)
   - Implementar FAQs integradas

**Entregables:**

- ✅ Hub de cotización funcional
- ✅ Todos los grids de productos
- ✅ Web embeds con prellenado
- ✅ Formulario de contacto
- ✅ Información de call center
- ✅ FAQs

---

### Fase 5: Siniestros y Wallet (Semana 9-10)

**Objetivo:** Implementar reporte de siniestros y wallet digital.

#### Tareas:

1. **Siniestros**
   - Implementar ClaimsProvider
   - Crear ClaimsPage con tabs
   - Implementar formulario de reporte
   - Implementar upload de fotos/videos
   - Implementar geolocalización
   - Implementar seguimiento de siniestros
   - Implementar chat con ajustador (placeholder)

2. **Wallet Digital**
   - Migrar GoogleWalletService
   - Migrar AppleWalletService
   - Implementar WalletProvider
   - Crear WalletPage con grid
   - Implementar vista previa de tarjetas
   - Implementar descarga directa
   - Implementar compartir tarjeta

**Entregables:**

- ✅ Reporte de siniestros funcional
- ✅ Upload de media
- ✅ Seguimiento de siniestros
- ✅ Wallet digital funcional
- ✅ Descarga de pases
- ✅ Compartir tarjetas

---

### Fase 6: Perfil y Configuración (Semana 11)

**Objetivo:** Implementar gestión de perfil y configuración de la app.

#### Tareas:

1. **Mi Perfil**
   - Implementar ProfileProvider
   - Crear ProfilePage con tabs
   - Implementar edición de datos personales
   - Implementar cambio de contraseña
   - Implementar configuración de biometría
   - Implementar historial de actividad

2. **Configuración**
   - Implementar SettingsProvider
   - Crear SettingsPage con secciones
   - Implementar selector de tema (claro/oscuro)
   - Implementar selector de idioma (ES/EN)
   - Implementar preferencias de notificaciones
   - Implementar configuración de 2FA
   - Implementar gestión de sesiones activas

**Entregables:**

- ✅ Gestión de perfil funcional
- ✅ Edición de datos
- ✅ Cambio de contraseña
- ✅ Configuración de tema
- ✅ Configuración de idioma
- ✅ Configuración de notificaciones
- ✅ Gestión de sesiones

---

### Fase 7: Testing y Optimización (Semana 12)

**Objetivo:** Testing, optimización y preparación para deploy.

#### Tareas:

1. **Testing**
   - Escribir tests unitarios para providers
   - Escribir tests de widgets
   - Escribir tests de integración
   - Testing responsive (desktop/tablet/mobile)
   - Testing cross-browser
   - Testing de accesibilidad

2. **Optimización**
   - Optimizar tamaño de bundle
   - Implementar lazy loading
   - Optimizar imágenes
   - Implementar caching
   - Optimizar API calls

3. **SEO**
   - Configurar meta tags
   - Implementar structured data
   - Configurar sitemap
   - Configurar robots.txt

4. **Deploy**
   - Configurar Firebase Hosting / Vercel
   - Configurar CI/CD
   - Configurar analytics
   - Configurar error tracking (Sentry)

**Entregables:**

- ✅ Suite de tests completa
- ✅ Aplicación optimizada
- ✅ SEO configurado
- ✅ Deploy en producción
- ✅ Analytics configurado
- ✅ Error tracking configurado

---

## ✅ Checklist por Fase

### Fase 1: Preparación y Setup

- [ ] Crear repositorio en GitHub
- [ ] Configurar branches y protections
- [ ] Inicializar proyecto Flutter Web
- [ ] Configurar pubspec.yaml
- [ ] Configurar analysis_options.yaml
- [ ] Crear estructura de carpetas
- [ ] Configurar constantes
- [ ] Setup de tema responsive
- [ ] Extraer servicios del mobile
- [ ] Extraer modelos del mobile
- [ ] Configurar GoRouter
- [ ] Definir rutas base
- [ ] Configurar guards de autenticación
- [ ] Implementar AppScaffold
- [ ] Implementar AppHeader
- [ ] Implementar AppSidemenu
- [ ] Configurar breakpoints responsive

### Fase 2: Autenticación y Dashboard

- [ ] Migrar AuthService
- [ ] Implementar AuthProvider (Riverpod)
- [ ] Crear LoginPage
- [ ] Crear RegisterPage
- [ ] Crear ForgotPasswordPage
- [ ] Implementar 2FA
- [ ] Implementar WebAuthn
- [ ] Implementar DashboardProvider
- [ ] Crear DashboardPage
- [ ] Implementar Hero Section
- [ ] Implementar Quick Actions
- [ ] Implementar Pólizas Activas
- [ ] Implementar Notification Panel
- [ ] Configurar localStorage
- [ ] Implementar refresh token
- [ ] Configurar cookies

### Fase 3: Pólizas y Oficinas

- [ ] Implementar PoliciesProvider
- [ ] Crear PoliciesPage
- [ ] Implementar filtros
- [ ] Implementar búsqueda
- [ ] Implementar vista de lista
- [ ] Implementar vista de grid
- [ ] Implementar exportar PDF
- [ ] Implementar comparar pólizas
- [ ] Migrar OfficeService
- [ ] Implementar OfficesProvider
- [ ] Crear OfficesPage
- [ ] Implementar mapa grande
- [ ] Implementar lista lateral
- [ ] Implementar búsqueda por ZIP
- [ ] Implementar filtros por servicios
- [ ] Integrar rutas Google Maps

### Fase 4: Cotización y Contacto

- [ ] Implementar QuoteProvider
- [ ] Crear QuotePage
- [ ] Implementar VehicleInsuranceGrid
- [ ] Implementar PropertyInsuranceGrid
- [ ] Implementar PersonalProtectionGrid
- [ ] Implementar BusinessInsuranceGrid
- [ ] Implementar AdditionalProductsGrid
- [ ] Integrar web embeds
- [ ] Implementar guardar cotizaciones
- [ ] Implementar compartir cotización
- [ ] Implementar ContactProvider
- [ ] Crear ContactPage
- [ ] Implementar formulario de contacto
- [ ] Implementar info call center
- [ ] Implementar chat placeholder
- [ ] Implementar FAQs

### Fase 5: Siniestros y Wallet

- [ ] Implementar ClaimsProvider
- [ ] Crear ClaimsPage
- [ ] Implementar formulario reporte
- [ ] Implementar upload media
- [ ] Implementar geolocalización
- [ ] Implementar seguimiento
- [ ] Implementar chat ajustador
- [ ] Migrar GoogleWalletService
- [ ] Migrar AppleWalletService
- [ ] Implementar WalletProvider
- [ ] Crear WalletPage
- [ ] Implementar vista previa tarjetas
- [ ] Implementar descarga directa
- [ ] Implementar compartir tarjeta

### Fase 6: Perfil y Configuración

- [ ] Implementar ProfileProvider
- [ ] Crear ProfilePage
- [ ] Implementar edición datos
- [ ] Implementar cambio contraseña
- [ ] Implementar biometría
- [ ] Implementar historial actividad
- [ ] Implementar SettingsProvider
- [ ] Crear SettingsPage
- [ ] Implementar selector tema
- [ ] Implementar selector idioma
- [ ] Implementar notificaciones
- [ ] Implementar 2FA
- [ ] Implementar sesiones activas

### Fase 7: Testing y Optimización

- [ ] Escribir tests unitarios
- [ ] Escribir tests widgets
- [ ] Escribir tests integración
- [ ] Testing responsive
- [ ] Testing cross-browser
- [ ] Testing accesibilidad
- [ ] Optimizar bundle
- [ ] Implementar lazy loading
- [ ] Optimizar imágenes
- [ ] Implementar caching
- [ ] Optimizar API calls
- [ ] Configurar meta tags
- [ ] Implementar structured data
- [ ] Configurar sitemap
- [ ] Configurar robots.txt
- [ ] Configurar Firebase/Vercel
- [ ] Configurar CI/CD
- [ ] Configurar analytics
- [ ] Configurar Sentry

---

## 🔧 Decisiones Técnicas

### 1. Riverpod vs Provider

**Decisión:** Riverpod  
**Justificación:**

- Mejor para web (no requiere BuildContext)
- Más escalable para aplicaciones grandes
- Testing más fácil
- Mejor performance con rebuilds selectivos

### 2. GoRouter vs Named Routes

**Decisión:** GoRouter  
**Justificación:**

- Deep linking nativo
- Clean URLs (`/policies` vs `/#/policies`)
- Guards de autenticación integrados
- Mejor para SEO
- Historial de navegación del navegador

### 3. flutter_screenutil vs Media Queries

**Decisión:** flutter_screenutil  
**Justificación:**

- Adaptación automática a diferentes tamaños
- Consistencia con diseño mobile
- Menos código boilerplate
- Soporte para breakpoints

### 4. Firebase Hosting vs Vercel

**Decisión:** Firebase Hosting (inicial), evaluar Vercel  
**Justificación:**

- Integración nativa con Flutter
- HTTPS automático
- CDN global
- Preview deployments
- Fácil rollback

### 5. Monorepo vs Multi-repo

**Decisión:** Multi-repo con código compartido  
**Justificación:**

- Separación clara de responsabilidades
- Deploy independiente
- Menos conflictos en desarrollo
- Escalabilidad a futuro

---

## ⚠️ Riesgos y Mitigación

| Riesgo                           | Probabilidad | Impacto | Mitigación                                                 |
| -------------------------------- | ------------ | ------- | ---------------------------------------------------------- |
| Performance en web               | Media        | Alto    | Implementar lazy loading, optimizar bundle, caching        |
| Cross-browser compatibility      | Alta         | Medio   | Testing extensivo, polyfills, progressive enhancement      |
| Integración web embeds           | Media        | Medio   | Validar URLs, implementar fallbacks                        |
| SEO en SPA                       | Media        | Alto    | Implementar SSR con Flutter Web, meta tags, sitemap        |
| Sincronización código compartido | Alta         | Medio   | Automatizar con scripts, versionado semántico              |
| Responsive design complejo       | Media        | Medio   | Usar flutter_screenutil, testing en múltiples dispositivos |
| Seguridad en web                 | Media        | Alto    | Implementar CSP, HTTPS, sanitización de inputs             |
| Deploy y CI/CD                   | Baja         | Medio   | Configurar desde el inicio, documentar proceso             |

---

## 📊 Métricas de Éxito

### Técnicas

- **Lighthouse Score:** >90 en todas las categorías
- **Time to Interactive:** <3 segundos
- **Bundle Size:** <2MB inicial
- **Cross-browser:** Compatible con Chrome, Firefox, Safari, Edge (últimas 2 versiones)

### Funcionales

- **Tasa de conversión:** >5% de visitantes a usuarios registrados
- **Tiempo en página:** >2 minutos promedio
- **Tasa de rebote:** <40%
- **Satisfacción usuario:** >4/5 estrellas

---

## 🎓 Recursos y Referencias

- [Flutter Web Documentation](https://flutter.dev/web)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://gorouter.dev)
- [flutter_screenutil](https://pub.dev/packages/flutter_screenutil)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)

---

**Última actualización:** Abril 2026  
**Mantenido por:** Equipo de Desarrollo Freeway Insurance
