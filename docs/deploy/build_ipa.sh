#!/bin/bash

# Script para generar IPA de producción para Freeway Insurance App
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
echo "║         Freeway Insurance - iOS IPA Builder                ║"
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
read -p "¿Deseas continuar con la generación del IPA? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}⚠️  Generación cancelada por el usuario.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🧹 Paso 1/6: Limpiando proyecto...${NC}"
fvm flutter clean
rm -rf ios/Pods ios/Podfile.lock
echo -e "${GREEN}✓ Limpieza completada${NC}"
echo ""

echo -e "${BLUE}📦 Paso 2/6: Obteniendo dependencias...${NC}"
fvm flutter pub get
echo -e "${GREEN}✓ Dependencias actualizadas${NC}"
echo ""

echo -e "${BLUE}🍎 Paso 3/6: Instalando pods de iOS...${NC}"
cd ios
pod install --repo-update
cd ..
echo -e "${GREEN}✓ Pods instalados${NC}"
echo ""

echo -e "${BLUE}🔍 Paso 4/6: Analizando código...${NC}"
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

echo -e "${BLUE}🏗️  Paso 5/6: Generando IPA de producción...${NC}"
echo -e "${YELLOW}⏳ Esto puede tomar varios minutos...${NC}"
fvm flutter build ipa --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ IPA generado exitosamente${NC}"
else
    echo -e "${RED}❌ Error al generar el IPA${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}📊 Paso 6/6: Verificando información del IPA...${NC}"
IPA_PATH="$PROJECT_DIR/build/ios/ipa/Freeway.ipa"

if [ -f "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    echo -e "${GREEN}✓ IPA encontrado${NC}"
    echo -e "  📍 Ubicación: ${IPA_PATH}"
    echo -e "  📏 Tamaño: ${IPA_SIZE}"
    echo -e "  🏷️  Versión: ${VERSION_NAME} (build: ${VERSION_CODE})"
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
    echo "  1. Abre Xcode: open ios/Runner.xcworkspace"
    echo "  2. O sube directamente a App Store Connect:"
    echo "     - Navega a https://appstoreconnect.apple.com"
    echo "     - Ve a 'My Apps' > Freeway Insurance"
    echo "     - Sube el IPA desde: ${IPA_PATH}"
    echo "  3. Completa la información de la versión"
    echo "  4. Envía para revisión"
    echo ""
    echo -e "${YELLOW}💡 Tip: También puedes usar Transporter app para subir el IPA${NC}"
    echo ""
else
    echo -e "${RED}❌ Error: No se encontró el IPA generado${NC}"
    exit 1
fi

# Preguntar si desea abrir la carpeta del IPA
read -p "¿Deseas abrir la carpeta del IPA? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    open "build/ios/ipa/"
fi

echo -e "${GREEN}🎉 ¡Proceso completado exitosamente!${NC}"
