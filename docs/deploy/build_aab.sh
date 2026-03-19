#!/bin/bash

# Script para generar AAB de producción para Freeway Insurance App
# Autor: Equipo de desarrollo
# Fecha: $(date +%Y-%m-%d)

set -e  # Detener el script si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║        Freeway Insurance - Android AAB Builder             ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Obtener el directorio del proyecto (2 niveles arriba de docs/deploy)
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
echo -e "${BLUE}📁 Directorio del proyecto: ${PROJECT_DIR}${NC}"
cd "$PROJECT_DIR"

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: No se encontró pubspec.yaml. Asegúrate de estar en el directorio correcto.${NC}"
    exit 1
fi

# Leer la versión actual del pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)
VERSION_CODE=$(echo $VERSION | cut -d'+' -f2)

echo -e "${GREEN}📦 Versión actual: ${VERSION_NAME} (${VERSION_CODE})${NC}"
echo ""

# Confirmar con el usuario
read -p "¿Deseas continuar con la generación del AAB? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}⚠️  Generación cancelada por el usuario.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🧹 Paso 1/5: Limpiando proyecto...${NC}"
fvm flutter clean
rm -rf android/app/build
echo -e "${GREEN}✓ Limpieza completada${NC}"
echo ""

echo -e "${BLUE}📦 Paso 2/5: Obteniendo dependencias...${NC}"
fvm flutter pub get
echo -e "${GREEN}✓ Dependencias actualizadas${NC}"
echo ""

echo -e "${BLUE}🔍 Paso 3/5: Analizando código...${NC}"
fvm flutter analyze --no-fatal-infos
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Advertencia: Se encontraron problemas en el análisis de código.${NC}"
    read -p "¿Deseas continuar de todas formas? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}⚠️  Generación cancelada.${NC}"
        exit 0
    fi
fi
echo -e "${GREEN}✓ Análisis completado${NC}"
echo ""

echo -e "${BLUE}🏗️  Paso 4/5: Generando AAB de producción...${NC}"
echo -e "${YELLOW}⏳ Esto puede tomar varios minutos...${NC}"
fvm flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ AAB generado exitosamente${NC}"
else
    echo -e "${RED}❌ Error al generar el AAB${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}📊 Paso 5/5: Verificando información del AAB...${NC}"
AAB_PATH="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    echo -e "${GREEN}✓ AAB encontrado${NC}"
    echo -e "  📍 Ubicación: ${AAB_PATH}"
    echo -e "  📏 Tamaño: ${AAB_SIZE}"
    echo -e "  🏷️  Versión: ${VERSION_NAME} (código: ${VERSION_CODE})"
    echo ""
    
    # Verificar versionCode en local.properties
    if [ -f "android/local.properties" ]; then
        LOCAL_VERSION_CODE=$(grep "flutter.versionCode" android/local.properties | cut -d'=' -f2)
        if [ "$LOCAL_VERSION_CODE" == "$VERSION_CODE" ]; then
            echo -e "${GREEN}✓ VersionCode verificado: ${LOCAL_VERSION_CODE}${NC}"
        else
            echo -e "${RED}⚠️  Advertencia: VersionCode en local.properties (${LOCAL_VERSION_CODE}) no coincide con pubspec.yaml (${VERSION_CODE})${NC}"
        fi
    fi
    echo ""
    
    # Resumen final
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║                  ✓ BUILD COMPLETADO                        ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}📤 Próximos pasos:${NC}"
    echo "  1. Navega a Google Play Console"
    echo "  2. Ve a la sección de 'Producción' o 'Prueba interna'"
    echo "  3. Sube el archivo: ${AAB_PATH}"
    echo "  4. Completa la información de la versión"
    echo "  5. Envía para revisión"
    echo ""
    echo -e "${YELLOW}💡 Tip: Guarda el archivo mapping.txt para poder depurar crashes:${NC}"
    echo "     build/app/outputs/mapping/release/mapping.txt"
    echo ""
else
    echo -e "${RED}❌ Error: No se encontró el AAB generado${NC}"
    exit 1
fi

# Preguntar si desea abrir la carpeta del AAB
read -p "¿Deseas abrir la carpeta del AAB? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    open "build/app/outputs/bundle/release/"
fi

echo -e "${GREEN}🎉 ¡Proceso completado exitosamente!${NC}"
