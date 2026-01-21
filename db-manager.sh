#!/bin/bash

# Database Management Script
# Script to manage PostgreSQL database

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DB_CONTAINER="datacenter-postgres"
DB_USER="datacenter_user"
DB_NAME="datacenter_db"

# Function to show menu
show_menu() {
    echo ""
    echo "DataCenter AI Monitor - Database Management"
    echo "=================================================="
    echo ""
    echo "1) Connect to PostgreSQL (psql)"
    echo "2) View infrastructure metrics"
    echo "3) View incidents"
    echo "4) View predictions"
    echo "5) Reset database (WARNING: Deletes all data)"
    echo "6) Generate additional test data"
    echo "7) Export database (backup)"
    echo "8) View statistics"
    echo "9) Exit"
    echo ""
}

# Function to connect to psql
connect_psql() {
    echo -e "${GREEN}[INFO] Connecting to PostgreSQL...${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME
}

# Function to view metrics
view_metrics() {
    echo -e "${GREEN}Infrastructure Metrics (last 20):${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT id, timestamp, device_id, metric_type, metric_value, status 
        FROM infrastructure_metrics 
        ORDER BY timestamp DESC 
        LIMIT 20;
    "
}

# Function to view incidents
view_incidents() {
    echo -e "${GREEN}Incidents (last 10):${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT id, created_at, device_id, severity, category, status, auto_resolved 
        FROM incidents 
        ORDER BY created_at DESC 
        LIMIT 10;
    "
}

# Function to view predictions
view_predictions() {
    echo -e "${GREEN}Failure Predictions:${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT * FROM predictions 
        ORDER BY probability DESC;
    "
}

# Function to reset database
reset_database() {
    echo -e "${RED}[WARN] WARNING: This will delete ALL data${NC}"
    read -p "Are you sure? Type 'YES' to confirm: " confirm
    
    if [ "$confirm" = "YES" ]; then
        echo -e "${YELLOW}[INFO] Resetting database...${NC}"
        
        # Drop and recreate tables
        docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
            DROP TABLE IF EXISTS automated_actions CASCADE;
            DROP TABLE IF EXISTS predictions CASCADE;
            DROP TABLE IF EXISTS incidents CASCADE;
            DROP TABLE IF EXISTS infrastructure_metrics CASCADE;
            DROP VIEW IF EXISTS incident_analytics CASCADE;
        "
        
        # Recreate schema
        docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < database/schema.sql
        
        # Insert test data
        docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < database/seed.sql
        
        echo -e "${GREEN}[OK] Database reset successfully${NC}"
    else
        echo "Operation cancelled"
    fi
}

# Function to generate additional data
generate_data() {
    echo -e "${GREEN}[INFO] Generating additional test data...${NC}"
    
    if [ -f "scripts/generate_metrics.py" ]; then
        python3 scripts/generate_metrics.py
        echo -e "${GREEN}[OK] Data generated successfully${NC}"
    else
        echo -e "${RED}[ERROR] Script generate_metrics.py not found${NC}"
    fi
}

# Function to export database
export_database() {
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${GREEN}[INFO] Exporting database to: $BACKUP_FILE${NC}"
    
    docker exec $DB_CONTAINER pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE
    
    echo -e "${GREEN}[OK] Backup created: $BACKUP_FILE${NC}"
}

# Function to view statistics
view_stats() {
    echo -e "${GREEN}Database Statistics:${NC}"
    echo ""
    
    echo "Record Count:"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT 
            'Metrics' as table_name, COUNT(*) as total FROM infrastructure_metrics
        UNION ALL
        SELECT 'Incidents', COUNT(*) FROM incidents
        UNION ALL
        SELECT 'Predictions', COUNT(*) FROM predictions
        UNION ALL
        SELECT 'Automated Actions', COUNT(*) FROM automated_actions;
    "
    
    echo ""
    echo "Status Distribution:"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT status, COUNT(*) as total 
        FROM infrastructure_metrics 
        GROUP BY status 
        ORDER BY total DESC;
    "
    
    echo ""
    echo "Incidents by Severity:"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT severity, COUNT(*) as total 
        FROM incidents 
        GROUP BY severity 
        ORDER BY severity DESC;
    "
}

# Check if container is running
if ! docker ps | grep -q $DB_CONTAINER; then
    echo -e "${RED}[ERROR] PostgreSQL container is not running${NC}"
    echo "Start services with: docker-compose up -d"
    exit 1
fi

# Main menu
while true; do
    show_menu
    read -p "Select an option: " choice
    
    case $choice in
        1) connect_psql ;;
        2) view_metrics ;;
        3) view_incidents ;;
        4) view_predictions ;;
        5) reset_database ;;
        6) generate_data ;;
        7) export_database ;;
        8) view_stats ;;
        9) echo "Goodbye"; exit 0 ;;
        *) echo -e "${RED}[ERROR] Invalid option${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
