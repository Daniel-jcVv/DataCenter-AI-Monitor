#!/bin/bash

# DataCenter AI Monitor - Quick Start Script
# Este script automatiza el despliegue del proyecto

set -e  # Salir si hay algún error

echo "DataCenter AI Monitor - Despliegue Rápido"
echo "=============================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker no está instalado${NC}"
    echo "Por favor instala Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar que Docker Compose esté instalado
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}[ERROR] Docker Compose no está instalado${NC}"
    echo "Por favor instala Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}[OK] Docker y Docker Compose detectados${NC}"
echo ""

# Verificar si existe el archivo .env
if [ ! -f .env ]; then
    echo -e "${YELLOW}[WARN] Archivo .env no encontrado${NC}"
    echo "Creando archivo .env de ejemplo..."
    cp .env.example .env 2>/dev/null || echo "No se encontró .env.example"
    echo -e "${YELLOW}[WARN] Por favor edita el archivo .env y agrega tu OPENAI_API_KEY${NC}"
    echo ""
fi

# Verificar si OPENAI_API_KEY está configurada
if grep -q "your-openai-api-key-here" .env 2>/dev/null; then
    echo -e "${YELLOW}[WARN] Necesitas configurar tu OPENAI_API_KEY en el archivo .env${NC}"
    echo ""
    read -p "¿Deseas continuar de todas formas? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Abortando..."
        exit 1
    fi
fi

# Detener contenedores existentes si los hay
echo "[INFO] Deteniendo contenedores existentes (si los hay)..."
docker-compose down 2>/dev/null || true
echo ""

# Construir e iniciar los contenedores
echo "[INFO] Construyendo e iniciando contenedores..."
echo "Esto puede tardar unos minutos la primera vez..."
echo ""

docker-compose up -d --build

# Esperar a que los servicios estén listos
echo ""
echo "[INFO] Esperando a que los servicios estén listos..."
sleep 10

# Verificar el estado de los contenedores
echo ""
echo "Estado de los servicios:"
docker-compose ps

# Verificar que PostgreSQL esté saludable
echo ""
echo "[INFO] Verificando PostgreSQL..."
for i in {1..30}; do
    if docker-compose exec -T postgres pg_isready -U datacenter_user -d datacenter_db &> /dev/null; then
        echo -e "${GREEN}[OK] PostgreSQL está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}[ERROR] PostgreSQL no respondió a tiempo${NC}"
        echo "Revisa los logs: docker-compose logs postgres"
        exit 1
    fi
    sleep 2
done

# Verificar datos de prueba
echo ""
echo "[INFO] Verificando datos de prueba en la base de datos..."
METRICS_COUNT=$(docker-compose exec -T postgres psql -U datacenter_user -d datacenter_db -t -c "SELECT COUNT(*) FROM infrastructure_metrics;" 2>/dev/null | tr -d ' ')

if [ "$METRICS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}[OK] Base de datos inicializada con $METRICS_COUNT métricas${NC}"
else
    echo -e "${YELLOW}[WARN] No se encontraron datos de prueba${NC}"
fi

# Mostrar información de acceso
echo ""
echo "=============================================="
echo -e "${GREEN}Despliegue completado exitosamente${NC}"
echo "=============================================="
echo ""
echo "URLs de Acceso:"
echo ""
echo "  n8n (Automatización):"
echo "     URL: http://localhost:5678"
echo "     Usuario: admin"
echo "     Contraseña: admin123"
echo ""
echo "  Dashboard (Streamlit):"
echo "     URL: http://localhost:8501"
echo ""
echo "  PostgreSQL:"
echo "     Host: localhost:5432"
echo "     Database: datacenter_db"
echo "     Usuario: datacenter_user"
echo ""
echo "=============================================="
echo ""
echo "Próximos pasos:"
echo ""
echo "  1. Accede a n8n: http://localhost:5678"
echo "  2. Configura las credenciales (PostgreSQL y OpenAI)"
echo "  3. Importa el workflow: workflows/01-monitor.json"
echo "  4. Ejecuta el workflow para probar"
echo "  5. Activa el workflow para monitoreo automático"
echo ""
echo "Para más información, consulta: DEPLOYMENT.md"
echo ""
echo "Comandos útiles:"
echo "  - Ver logs: docker-compose logs -f"
echo "  - Detener: docker-compose down"
echo "  - Reiniciar: docker-compose restart"
echo ""
