# Flujo de la Aplicacion

## Flujo principal de navegacion

```mermaid
flowchart TD
    A["App start"] --> B["AuthSplashScreen"]
    B --> C{"checkAuthStatus()"}
    C -->|Sesion valida| D["HomePage"]
    C -->|Sin sesion| E["LoginPage"]

    E --> F["POST /api/Mobile/Login"]
    F --> G{"requiresTwoFactor"}
    G -->|Si| H["TwoFactorDialog"]
    H --> I["POST /api/Mobile/Login con 2FA"]
    G -->|No| D
    I --> D

    E --> J["SignUpPage"]
    J --> K["POST /api/Mobile/Register"]
    K --> L["Login automatico"]
    L --> D

    E --> M["ForgotPasswordPage"]
    M --> N["POST /api/Mobile/SendForgotPasswordMessage"]
    M --> O["POST /api/Mobile/ResetPassword"]
    O --> E

    D --> P["ProfilePage"]
    P --> Q["UserDataPage"]
    Q --> R["POST /api/Mobile/User"]
    P --> S["PasswordChangePage"]
    S --> T["POST /api/Mobile/ChangePassword"]
    P --> U["LanguageSelectionPage"]
    P --> V["AppInfoPage"]

    D --> W["IdCardPage"]
    W --> X["POST /DownloadGooglePassTask"]
    W --> Y["POST //DownloadApplePassTask"]

    D --> Z["SubmitClaimPage"]
    Z --> ZA["Telefono o URL del carrier"]

    D --> ZB["AddInsurancePage"]
    ZB --> ZC["Validacion ZIP"]
    ZC --> ZD["WebViewPage con cotizador / formulario"]

    D --> ZE["LocationDetailsView"]
    ZE --> ZF["POST /api/StoreLocator"]
    ZE --> ZG["Google Maps / Apple Maps"]
```

## Flujo de autenticacion y estado

```mermaid
flowchart LR
    A["LoginPage"] --> B["AuthProvider"]
    B --> C["AuthService"]
    C --> D["/api/Mobile/Login"]
    D --> E["LoginResponse"]
    E --> B
    B --> F["SecureStorage"]
    B --> G["currentUser + token + policies"]
    G --> H["HomePage"]
    G --> I["ProfilePage"]
    G --> J["IdCardPage"]
```

## Flujo de Add Insurance

```mermaid
flowchart TD
    A["AddInsurancePage"] --> B["VehicleInsuranceGrid"]
    A --> C["PropertyInsuranceGrid"]
    A --> D["PersonalProtectionGrid"]
    A --> E["BusinessInsuranceGrid"]
    A --> F["AdditionalProductsGrid"]

    B --> G["LocationService.validateZipCode()"]
    C --> G
    D --> G
    E --> G
    F --> G

    G --> H["GET api.zippopotam.us/us/{zip}"]
    H --> I["Ciudad / estado / coordenadas"]
    I --> J["WebViewPage"]
    J --> K["Formulario web externo prellenado"]
```

## Flujo de localizacion

```mermaid
flowchart TD
    A["LocationDetailsView"] --> B{"Permiso de ubicacion"}
    B -->|Con permiso| C["GetCurrentLocation"]
    B -->|Sin permiso| D["ZIP manual"]

    C --> E["GetOffices.execute(currentPosition)"]
    E --> F["POST /api/StoreLocator"]

    D --> G["searchByZipCode(zip)"]
    G --> H["OfficeService.getNearbyOfficesWithIncrementalRadius"]
    H --> F

    F --> I["Markers + lista de oficinas"]
    I --> J["Abrir ruta externa en Google Maps"]
```

## Flujo de WebView

```mermaid
flowchart LR
    A["Pantalla nativa"] --> B["WebViewPage"]
    B --> C["Carga URL externa"]
    B --> D["Inyecta JavaScript de autollenado"]
    D --> E["Usa userData del AuthProvider"]
```

## Notas de flujo

- La app arranca en `AuthSplashScreen`, no en `SplashScreen`.
- `SplashScreen` existe como utilidad generica, pero no esta registrada en las rutas principales.
- El flujo de `HomePage` depende fuertemente de `AuthProvider.currentUser`.
- El flujo de `LocationDetailsView` tiene doble entrada: geolocalizacion o ZIP manual.
- El flujo de productos esta hibrido: arranca en Flutter, pero el cierre del journey ocurre en formularios web.

