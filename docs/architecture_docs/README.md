# Architecture Docs

Esta carpeta documenta la arquitectura funcional de la app Flutter, el flujo principal de navegacion y las APIs o integraciones usadas por cada pantalla.

## Archivos

- `architecture_overview.md`: capas, modulos, providers, servicios y endpoints base.
- `application_flow.md`: diagramas de flujo de navegacion y de datos.
- `screen_api_inventory.md`: inventario pantalla por pantalla con APIs, servicios externos y notas de implementacion.
- `diagrams/`: fuentes Mermaid en formato `.mmd`.
- `images/`: exportaciones `.png` generadas desde Mermaid.

## Alcance

La documentacion fue levantada a partir del codigo actual del proyecto, principalmente desde:

- `lib/main.dart`
- `lib/pages/`
- `lib/widgets/`
- `lib/providers/`
- `lib/data/services/`
- `lib/locatordevice/`

## Convenciones usadas

- `API backend`: endpoints HTTP propios consumidos directamente desde la app.
- `Servicio externo`: integracion HTTP con un tercero.
- `Web embed`: sitio o formulario web abierto dentro de `WebViewPage`.
- `Sin consumo directo`: la pantalla usa estado local, `Provider`, almacenamiento seguro o capacidades nativas, pero no hace una llamada HTTP propia.

## PNG generados

- `images/architecture_overview.png`
- `images/application_flow.png`
- `images/auth_screen_api_map.png`
- `images/home_screen_api_map.png`
- `images/profile_screen_api_map.png`
- `images/add_insurance_screen_api_map.png`
- `images/location_screen_api_map.png`
- `images/id_card_screen_api_map.png`
