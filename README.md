# Freeway Insurance - Localizador de Oficinas

## Descripción

Módulo de localización para la aplicación Freeway Insurance. Este módulo permite:

- Obtener la ubicación actual del dispositivo
- Mostrar oficinas cercanas ordenadas por distancia
- Ver detalles de cada oficina (dirección, horario, etc.)
- Visualizar ubicaciones en un mapa

## Estructura del Proyecto

El proyecto sigue una arquitectura de Clean Architecture:

```
lib/
└── locatordevice/
    ├── di/                   # Dependency Injection
    ├── domain/               # Reglas de negocio y entidades
    │   ├── entities/         # Modelos de dominio
    │   ├── repositories/     # Interfaces de repositorios
    │   └── usecases/         # Casos de uso
    ├── data/                 # Implementaciones de datos
    │   ├── datasources/      # Fuentes de datos
    │   └── repositories/     # Implementaciones de repositorios
    └── presentation/         # Capa de presentación
        ├── bloc/             # Gestión de estado
        ├── pages/            # Pantallas
        └── widgets/          # Componentes reutilizables
```

## Dependencias

- flutter_bloc (BLoC para gestión de estado)
- get_it (inyección de dependencias)
- geolocator (servicios de localización)

## Instalación

1. Asegúrate de tener configurado Flutter correctamente
2. Clona este repositorio
3. Ejecuta `flutter pub get` para descargar las dependencias
4. Ejecuta `flutter run` para iniciar la aplicación

## Uso

Para utilizar el módulo de localización en el menú:

```dart
import 'package:freeway/locatordevice/locator_device_module.dart';

// ...

onPressed: () {
  LocatorDeviceModule.navigateToLocationView(context);
}
```

## Credenciales

DEVELOPMENT

Usuario 1

- user: jorge.cacho-sousa@freeway.com
- password: Freeway!1

Usuario 2

- user: uzzielpalma99@gmail.com
- password: Cbluna2025$

Usuario 3

- user: omar.neftali.rocha.gallaga@confie.com
- password: Today2025!

PRODUCCIÓN

Usuario 4

- user: jorge.cacho-sousa@confie.com
- password: Freeway1!

Usuario 5

- user: mobapp@yopmail.com
- password: Today_2025!

Usuario 6

- user: hectorslop1@gmail.com
- password: Cbluna2025!
