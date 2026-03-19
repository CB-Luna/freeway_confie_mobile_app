#!/bin/bash

# Script para generar AAB e IPA de producción para Freeway Insurance App
# Autor: Equipo de desarrollo
# Fecha: $(date +%Y-%m-%d)

set -e  # Detener el script si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${MAGENTA}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║      Freeway Insurance - Multi-Platform Builder           ║"
echo "║              (Android AAB + iOS IPA)                       ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Obtener el directorio del script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Leer la versión actual del pubspec.yaml
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_DIR"

VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)
VERSION_CODE=$(echo $VERSION | cut -d'+' -f2)

echo -e "${GREEN}📦 Versión actual: ${VERSION_NAME} (${VERSION_CODE})${NC}"
echo ""

# Menú de selección
echo -e "${BLUE}Selecciona qué builds deseas generar:${NC}"
echo "  1) Solo Android (AAB)"
echo "  2) Solo iOS (IPA)"
echo "  3) Ambos (AAB + IPA)"
echo ""
read -p "Opción (1-3): " -n 1 -r OPTION
echo ""
echo ""

case $OPTION in
    1)
        echo -e "${BLUE}🤖 Generando solo Android AAB...${NC}"
        echo ""
        bash "$SCRIPT_DIR/build_aab.sh"
        ;;
    2)
        echo -e "${BLUE}🍎 Generando solo iOS IPA...${NC}"
        echo ""
        bash "$SCRIPT_DIR/build_ipa.sh"
        ;;
    3)
        echo -e "${MAGENTA}🚀 Generando ambos builds...${NC}"
        echo ""
        
        # Android primero
        echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}                    ANDROID BUILD                          ${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        bash "$SCRIPT_DIR/build_aab.sh"
        
        echo ""
        echo ""
        
        # iOS después
        echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}                      iOS BUILD                            ${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        bash "$SCRIPT_DIR/build_ipa.sh"
        
        echo ""
        echo ""
        
        # Resumen final
        echo -e "${MAGENTA}"
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║                                                            ║"
        echo "║            ✓ TODOS LOS BUILDS COMPLETADOS                  ║"
        echo "║                                                            ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo ""
        echo -e "${GREEN}📦 Archivos generados:${NC}"
        echo -e "  🤖 Android: build/app/outputs/bundle/release/app-release.aab"
        echo -e "  🍎 iOS:     build/ios/ipa/Freeway.ipa"
        echo ""
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✨ ¡Proceso completado!${NC}"
