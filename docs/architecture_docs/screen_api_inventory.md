# Inventario de Pantallas y APIs

## 1. Pantallas principales

| Pantalla | Ruta / acceso | Consumo | APIs o integraciones | Notas |
| --- | --- | --- | --- | --- |
| `AuthSplashScreen` | `/` | Indirecto | puede disparar `POST /api/Mobile/Login` via `checkAuthStatus()` y `_silentLogin()` | valida sesion restaurando token + credenciales guardadas |
| `LoginPage` | `/login` | Directo | `POST /api/Mobile/Login` | soporta login normal, login con biometria y 2FA |
| `ForgotPasswordPage` | desde login | Directo | `POST /api/Mobile/SendForgotPasswordMessage`, `POST /api/Mobile/ResetPassword` | flujo de recuperacion por SMS o email |
| `SignUpPage` | desde login | Directo | `POST /api/Mobile/Register`, luego `POST /api/Mobile/Login` | hace login automatico si el registro fue exitoso |
| `HomePage` | `/home` | Mixto | sin API propia de polizas; `NotificationProvider` hoy no pega a backend; abre WebViews y subflujos | las polizas vienen del login, no de una llamada dedicada |
| `ProfilePage` | `/profile` | Sin consumo directo | usa `AuthProvider.currentUser` | pantalla contenedora para ajustes y perfil |
| `UserDataPage` | desde profile | Directo | `POST /api/Mobile/User` | actualiza telefono o datos del usuario |
| `PasswordChangePage` | desde profile | Directo | `POST /api/Mobile/ChangePassword` | limpia cookies y actualiza credenciales guardadas |
| `LanguageSelectionPage` | desde profile | Sin consumo directo | `SharedPreferences` via `LanguageProvider` | no hace HTTP |
| `AppInfoPage` | desde profile | Sin consumo backend | abre `terms-of-use` y `privacy-policy` en `WebViewPage` | tambien usa `device_info_plus` y `package_info_plus` |
| `AddInsurancePage` | `/add-insurance` | Sin consumo directo | navega a grids de productos | es un hub, no llama red por si mismo |
| `LocationDetailsView` | `/location` | Directo | `POST /api/StoreLocator`, Google Maps SDK, Google Maps URL | modulo de oficinas y mapa |
| `IdCardPage` | desde tarjeta de poliza | Directo | `POST /DownloadGooglePassTask`, `POST //DownloadApplePassTask` | genera pases para wallet |
| `SubmitClaimPage` | `/submit-claim` o desde poliza | Sin API backend directa | `tel:` o URL del carrier desde datos de poliza | depende de metadata de la poliza |
| `RequestCallPage` | desde home/profile/location | Sin consumo backend | `tel:` al call center | integra capacidades nativas del dispositivo |
| `WebViewPage` | desde multiples flujos | Sin API propia, pero renderiza integraciones externas | `freeway.com`, `buy.freeway.com`, `triton.freeway.com`, `rate.freeway.com`, `quote.sanborns.com`, `carregistration.com`, `taxmax.com`, `quickpay.freeway.com` | inyecta JS para prellenar formularios |

## 2. HomePage y subflujos

| Componente dentro de Home | Consumo | APIs o integraciones | Notas |
| --- | --- | --- | --- |
| `HeaderSection` | Sin HTTP | `AuthProvider`, `SecureStorage` | muestra nombre e info del usuario |
| `CardSwiperSection` | Sin HTTP propio | usa polizas ya cargadas en login | base para ID card, submit claim y quick pay |
| `PolicyCard` -> ID Card | Directo | wallet endpoints | abre `IdCardPage` |
| `PolicyCard` -> Submit Claim | Sin HTTP propio | `tel:` o `carrierClaimUrl` | abre `SubmitClaimPage` |
| `PolicyCard` -> Quick Pay | Web embed | `quickpay.freeway.com/PolicySearch` | navega a `WebViewPage` |
| `RoadsideHelp` | Web embed | `buy.freeway.com/app/auto-club?utm_medium=app` | opcionalmente muestra dialogo previo |
| `ProductList` -> Roadside | Web embed | `buy.freeway.com/app/auto-club?utm_medium=app` | prellena formulario via `WebViewPage` |
| `ProductList` -> Motorcycle | Web embed | `freeway.com/motorcycle-insurance-quote-form/` | usa datos del usuario |
| `ProductList` -> Renters | Web embed | `freeway.com/renters-insurance-quote-form/` | usa ZIP/ciudad/estado del usuario |
| `ContactAgent` | Sin backend | `RequestCallPage` | no llama API |
| `NotificationProvider` | Preparado pero desactivado | existe `NotificationService` con webhook n8n | hoy devuelve lista vacia localmente |

## 3. Add Insurance: grids y APIs

Todos los grids siguen el mismo patron base:

1. Reciben datos del usuario desde `AuthProvider`.
2. Piden o validan un ZIP con `LocationService.validateZipCode()`.
3. Consumen `GET https://api.zippopotam.us/us/{zip}`.
4. Construyen una URL externa.
5. Abren `WebViewPage` para completar el journey web.

| Pantalla / widget | Servicio previo | Integraciones finales |
| --- | --- | --- |
| `VehicleInsuranceGrid` | `LocationService.validateZipCode()` | `triton.freeway.com`, `freeway.com`, `quote.sanborns.com` |
| `PropertyInsuranceGrid` | `LocationService.validateZipCode()` | `freeway.com/homeowner-insurance-quote-form/`, `freeway.com/renters-insurance-quote-form/`, `freeway.com/mobile-home-insurance-quote/` |
| `PersonalProtectionGrid` | `LocationService.validateZipCode()` | `freeway.com`, `buy.freeway.com/app/telemedicine`, `buy.freeway.com/app/ad-d`, `buy.freeway.com/app/identity-theft`, `quote.sanborns.com` |
| `BusinessInsuranceGrid` | `LocationService.validateZipCode()` | `freeway.com/business-insurance-quote-form/`, `freeway.com/landlord-insurance-quote-form/`, `freeway.com/commercial-vehicle-insurance-quote-form/`, `rate.freeway.com` |
| `AdditionalProductsGrid` | `LocationService.validateZipCode()` | `freeway.com`, `buy.freeway.com/app/*`, `carregistration.com`, `taxmax.com`, `triton.freeway.com` |

## 4. LocationDetailsView

| Caso | Consumo | API |
| --- | --- | --- |
| Carga inicial con permisos | Directo | `POST https://inquiry.confie.com/api/StoreLocator` por coordenadas |
| Busqueda manual por ZIP | Directo | `POST https://inquiry.confie.com/api/StoreLocator` con radio incremental |
| Validacion de ubicacion del dispositivo | Nativo | `geolocator` |
| Apertura de ruta | Externo | `https://www.google.com/maps/` |

Notas:

- El modulo usa `GoogleMap` para render de mapa.
- Si no hay permisos, puede trabajar con ZIP manual.
- `LocationService` valida ZIP en otros flujos, pero el locator usa `OfficeService` para resolver oficinas.

## 5. Wallet

| Pantalla | API | Metodo | Proposito |
| --- | --- | --- | --- |
| `IdCardPage` -> Google Wallet | `https://confie-wallet-api.azurewebsites.net/DownloadGooglePassTask` | `POST` | generar URL del pase y abrir Google Wallet |
| `IdCardPage` -> Apple Wallet | `https://confie-wallet-api.azurewebsites.net//DownloadApplePassTask` | `POST` | generar `.pkpass` y agregarlo al wallet |

## 6. Auth y perfil

| Pantalla | API | Metodo | Proposito |
| --- | --- | --- | --- |
| `LoginPage` | `/api/Mobile/Login` | `POST` | autenticar usuario, recuperar customer, policies y token |
| `SignUpPage` | `/api/Mobile/Register` | `POST` | crear usuario |
| `ForgotPasswordPage` | `/api/Mobile/SendForgotPasswordMessage` | `POST` | enviar codigo de recuperacion |
| `ForgotPasswordPage` | `/api/Mobile/ResetPassword` | `POST` | restablecer password |
| `UserDataPage` | `/api/Mobile/User` | `POST` | actualizar perfil y telefono |
| `PasswordChangePage` | `/api/Mobile/ChangePassword` | `POST` | cambiar password |

## 7. Pantallas sin consumo HTTP directo

Estas pantallas hoy no consumen una API por si mismas:

- `ProfilePage`
- `LanguageSelectionPage`
- `RequestCallPage`
- `SubmitClaimPage`
- `SplashScreen`
- `AddInsurancePage`

En estos casos el valor de la pantalla esta en:

- navegacion,
- render de estado ya disponible,
- integracion nativa del dispositivo,
- o apertura de subflujos externos.

## 8. Hallazgos importantes

1. La API de notificaciones existe, pero no esta conectada al `NotificationProvider`.
2. Las polizas no se refrescan con endpoint propio; dependen del login actual o de restaurar sesion.
3. `WebViewPage` es una pieza central del producto porque completa journeys comerciales fuera del backend Flutter.
4. El locator de oficinas es el modulo con integracion mas "backend-driven" fuera de autenticacion.
5. La documentacion de pantallas debe leerse junto con el estado real del codigo: hay rutas centrales en `main.dart`, pero tambien varias pantallas se alcanzan desde widgets internos.
