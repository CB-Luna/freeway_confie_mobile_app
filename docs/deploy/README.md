# 🚀 Scripts de Deploy - Freeway Insurance

Este directorio contiene scripts automatizados para generar builds de producción de la aplicación Freeway Insurance.

## 📱 Scripts Disponibles

- **`build_aab.sh`** - Genera Android App Bundle (AAB) para Google Play
- **`build_ipa.sh`** - Genera iOS App Archive (IPA) para App Store
- **`build_all.sh`** - Menú interactivo para generar AAB, IPA o ambos

---

## 📦 build_aab.sh

Script automatizado para generar el Android App Bundle (AAB) de producción.

### ✨ Características

- ✅ Limpieza automática del proyecto
- ✅ Actualización de dependencias
- ✅ Análisis de código
- ✅ Generación del AAB de producción
- ✅ Verificación de versión
- ✅ Resumen detallado del build
- ✅ Interfaz colorida y amigable

### 🎯 Uso

Desde el directorio raíz del proyecto o desde cualquier ubicación:

```bash
# Opción 1: Ejecutar desde el directorio raíz
./docs/deploy/build_aab.sh

# Opción 2: Ejecutar desde docs/deploy
cd docs/deploy
./build_aab.sh

# Opción 3: Ejecutar desde cualquier ubicación
bash /ruta/completa/al/proyecto/docs/deploy/build_aab.sh
```

### 📋 Proceso del Script

El script ejecuta los siguientes pasos:

1. **🧹 Limpieza del proyecto**
   - Ejecuta `flutter clean`
   - Elimina `android/app/build`

2. **📦 Actualización de dependencias**
   - Ejecuta `flutter pub get`

3. **🔍 Análisis de código**
   - Ejecuta `flutter analyze`
   - Permite continuar si hay warnings

4. **🏗️ Generación del AAB**
   - Ejecuta `flutter build appbundle --release`
   - Muestra progreso en tiempo real

5. **📊 Verificación**
   - Verifica que el AAB se generó correctamente
   - Muestra tamaño del archivo
   - Verifica versionCode
   - Muestra ubicación del archivo

### 📤 Salida

El AAB generado se encuentra en:

```
build/app/outputs/bundle/release/app-release.aab
```

El archivo de mapping (para debug de crashes) se encuentra en:

```
build/app/outputs/mapping/release/mapping.txt
```

### ⚙️ Requisitos

- **FVM** instalado y configurado
- **Flutter SDK** (versión gestionada por FVM)
- **Android SDK** configurado
- **key.properties** configurado en `android/key.properties`
- **Keystore** disponible para firma de release

### 🔧 Configuración de Versión

La versión se configura en `pubspec.yaml`:

```yaml
version: 1.0.8+26
#        ^^^^^ ^^
#        |     |
#        |     +-- versionCode (número entero, debe incrementarse en cada release)
#        +-------- versionName (versión visible para usuarios)
```

**Importante:** Siempre incrementa el `versionCode` antes de generar un nuevo AAB para Google Play.

### 🐛 Solución de Problemas

#### Error: "versionCode ya usado"

- Incrementa el número después del `+` en `pubspec.yaml`
- Ejemplo: `1.0.8+26` → `1.0.8+27`

#### Error: "No se encontró pubspec.yaml"

- Asegúrate de ejecutar el script desde el directorio correcto
- El script automáticamente navega al directorio raíz del proyecto

#### Error: "keystore no encontrado"

- Verifica que `android/key.properties` existe
- Verifica que el archivo keystore existe en la ruta especificada

#### Build falla con errores de Gradle

- Ejecuta manualmente: `cd android && ./gradlew clean`
- Verifica que Android SDK esté actualizado

### 📝 Notas

- El script usa `fvm` para gestionar la versión de Flutter
- Si no usas FVM, modifica el script reemplazando `fvm flutter` por `flutter`
- El script requiere confirmación del usuario antes de continuar
- Los colores en la terminal mejoran la legibilidad del proceso

### 🎨 Personalización

Puedes modificar el script para:

- Cambiar los colores del output
- Agregar pasos adicionales (tests, linting, etc.)
- Modificar las verificaciones
- Agregar notificaciones (Slack, email, etc.)

### 📞 Soporte

Si encuentras problemas con el script:

1. Verifica que todos los requisitos estén instalados
2. Revisa los logs de error
3. Contacta al equipo de desarrollo

---

## 🍎 build_ipa.sh

Script automatizado para generar el iOS App Archive (IPA) de producción.

### ✨ Características

- ✅ Limpieza automática del proyecto
- ✅ Actualización de dependencias
- ✅ Instalación de CocoaPods
- ✅ Análisis de código
- ✅ Generación del IPA de producción
- ✅ Verificación de versión
- ✅ Resumen detallado del build
- ✅ Interfaz colorida y amigable

### 🎯 Uso

```bash
# Opción 1: Ejecutar desde el directorio raíz
./docs/deploy/build_ipa.sh

# Opción 2: Ejecutar desde docs/deploy
cd docs/deploy
./build_ipa.sh
```

### 📋 Proceso del Script

1. **🧹 Limpieza del proyecto**
   - Ejecuta `flutter clean`
   - Elimina `ios/Pods` y `ios/Podfile.lock`

2. **📦 Actualización de dependencias**
   - Ejecuta `flutter pub get`

3. **🍎 Instalación de pods**
   - Ejecuta `pod install --repo-update`

4. **🔍 Análisis de código**
   - Ejecuta `flutter analyze`

5. **🏗️ Generación del IPA**
   - Ejecuta `flutter build ipa --release`

6. **📊 Verificación**
   - Verifica que el IPA se generó correctamente
   - Muestra información del archivo

### 📤 Salida

El IPA generado se encuentra en:

```
build/ios/ipa/Freeway.ipa
```

### ⚙️ Requisitos Adicionales para iOS

- **Xcode** instalado (versión 26.3 o superior)
- **CocoaPods** instalado
- **Certificados de firma** configurados en Xcode
- **Provisioning Profile** válido

### 📤 Subir a App Store

Puedes subir el IPA de dos formas:

1. **Usando Transporter (Recomendado)**
   - Abre la app Transporter
   - Arrastra el archivo IPA
   - Sube a App Store Connect

2. **Usando Xcode**
   - Abre: `open ios/Runner.xcworkspace`
   - Product > Archive
   - Distribute App

---

## 🎯 build_all.sh

Script interactivo que permite generar AAB, IPA o ambos desde un menú único.

### ✨ Características

- ✅ Menú interactivo de selección
- ✅ Opción para generar solo Android
- ✅ Opción para generar solo iOS
- ✅ Opción para generar ambos automáticamente
- ✅ Resumen consolidado de todos los builds

### 🎯 Uso

```bash
./docs/deploy/build_all.sh
```

El script mostrará un menú:

```
Selecciona qué builds deseas generar:
  1) Solo Android (AAB)
  2) Solo iOS (IPA)
  3) Ambos (AAB + IPA)

Opción (1-3):
```

### 💡 Recomendado para

- Releases que requieren ambas plataformas
- Testing de builds completos
- Automatización de CI/CD

---

## 🔄 Workflow Recomendado

### Opción 1: Build Individual

**Para Android:**

```bash
# 1. Incrementar versión en pubspec.yaml
# version: 1.0.8+26 → 1.0.8+27

# 2. Ejecutar script
./docs/deploy/build_aab.sh

# 3. Subir a Google Play Console
```

**Para iOS:**

```bash
# 1. Incrementar versión en pubspec.yaml
# version: 1.0.8+26 → 1.0.8+27

# 2. Ejecutar script
./docs/deploy/build_ipa.sh

# 3. Subir a App Store Connect
```

### Opción 2: Build Múltiple (Recomendado)

```bash
# 1. Incrementar versión en pubspec.yaml
# version: 1.0.8+26 → 1.0.8+27

# 2. Ejecutar script interactivo
./docs/deploy/build_all.sh

# 3. Seleccionar opción 3 (Ambos)

# 4. Subir ambos archivos a sus respectivas plataformas
```

---

**Última actualización:** Marzo 2026  
**Mantenido por:** Equipo de Desarrollo Freeway Insurance
