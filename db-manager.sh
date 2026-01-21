#!/bin/bash

# Database Management Script
# Script para gestionar la base de datos PostgreSQL

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DB_CONTAINER="datacenter-postgres"
DB_USER="datacenter_user"
DB_NAME="datacenter_db"

# Función para mostrar el menú
show_menu() {
    echo ""
    echo "DataCenter AI Monitor - Gestión de Base de Datos"
    echo "=================================================="
    echo ""
    echo "1) Conectar a PostgreSQL (psql)"
    echo "2) Ver métricas de infraestructura"
    echo "3) Ver incidentes"
    echo "4) Ver predicciones"
    echo "5) Reiniciar base de datos (ADVERTENCIA: Borra todos los datos)"
    echo "6) Generar datos de prueba adicionales"
    echo "7) Exportar base de datos (backup)"
    echo "8) Ver estadísticas"
    echo "9) Salir"
    echo ""
}

# Función para conectar a psql
connect_psql() {
    echo -e "${GREEN}[INFO] Conectando a PostgreSQL...${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME
}

# Función para ver métricas
view_metrics() {
    echo -e "${GREEN}Métricas de Infraestructura (últimas 20):${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT id, timestamp, device_id, metric_type, metric_value, status 
        FROM infrastructure_metrics 
        ORDER BY timestamp DESC 
        LIMIT 20;
    "
}

# Función para ver incidentes
view_incidents() {
    echo -e "${GREEN}Incidentes (últimos 10):${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT id, created_at, device_id, severity, category, status, auto_resolved 
        FROM incidents 
        ORDER BY created_at DESC 
        LIMIT 10;
    "
}

# Función para ver predicciones
view_predictions() {
    echo -e "${GREEN}Predicciones de Fallos:${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT * FROM predictions 
        ORDER BY probability DESC;
    "
}

# Función para reiniciar la base de datos
reset_database() {
    echo -e "${RED}[WARN] ADVERTENCIA: Esto borrará TODOS los datos${NC}"
    read -p "¿Estás seguro? Escribe 'SI' para confirmar: " confirm
    
    if [ "$confirm" = "SI" ]; then
        echo -e "${YELLOW}[INFO] Reiniciando base de datos...${NC}"
        
        # Eliminar y recrear las tablas
        docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
            DROP TABLE IF EXISTS automated_actions CASCADE;
            DROP TABLE IF EXISTS predictions CASCADE;
            DROP TABLE IF EXISTS incidents CASCADE;
            DROP TABLE IF EXISTS infrastructure_metrics CASCADE;
            DROP VIEW IF EXISTS incident_analytics CASCADE;
        "
        
        # Recrear el esquema
        docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < database/schema.sql
        
        # Insertar datos de prueba
        docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < database/seed.sql
        
        echo -e "${GREEN}[OK] Base de datos reiniciada exitosamente${NC}"
    else
        echo "Operación cancelada"
    fi
}

# Función para generar datos adicionales
generate_data() {
    echo -e "${GREEN}[INFO] Generando datos de prueba adicionales...${NC}"
    
    if [ -f "scripts/generate_metrics.py" ]; then
        python3 scripts/generate_metrics.py
        echo -e "${GREEN}[OK] Datos generados exitosamente${NC}"
    else
        echo -e "${RED}[ERROR] Script generate_metrics.py no encontrado${NC}"
    fi
}

# Función para exportar base de datos
export_database() {
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${GREEN}[INFO] Exportando base de datos a: $BACKUP_FILE${NC}"
    
    docker exec $DB_CONTAINER pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE
    
    echo -e "${GREEN}[OK] Backup creado: $BACKUP_FILE${NC}"
}

# Función para ver estadísticas
view_stats() {
    echo -e "${GREEN}Estadísticas de la Base de Datos:${NC}"
    echo ""
    
    echo "Conteo de Registros:"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT 
            'Métricas' as tabla, COUNT(*) as total FROM infrastructure_metrics
        UNION ALL
        SELECT 'Incidentes', COUNT(*) FROM incidents
        UNION ALL
        SELECT 'Predicciones', COUNT(*) FROM predictions
        UNION ALL
        SELECT 'Acciones Automatizadas', COUNT(*) FROM automated_actions;
    "
    
    echo ""
    echo "Distribución de Estados:"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT status, COUNT(*) as total 
        FROM infrastructure_metrics 
        GROUP BY status 
        ORDER BY total DESC;
    "
    
    echo ""
    echo "Incidentes por Severidad:"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT severity, COUNT(*) as total 
        FROM incidents 
        GROUP BY severity 
        ORDER BY severity DESC;
    "
}

# Verificar que el contenedor esté corriendo
if ! docker ps | grep -q $DB_CONTAINER; then
    echo -e "${RED}[ERROR] El contenedor de PostgreSQL no está corriendo${NC}"
    echo "Inicia los servicios con: docker-compose up -d"
    exit 1
fi

# Menú principal
while true; do
    show_menu
    read -p "Selecciona una opción: " choice
    
    case $choice in
        1) connect_psql ;;
        2) view_metrics ;;
        3) view_incidents ;;
        4) view_predictions ;;
        5) reset_database ;;
        6) generate_data ;;
        7) export_database ;;
        8) view_stats ;;
        9) echo "Hasta luego"; exit 0 ;;
        *) echo -e "${RED}[ERROR] Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
done
