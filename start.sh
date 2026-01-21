#!/bin/bash

# DataCenter AI Monitor - Quick Start Script
# This script automates the project deployment

set -e  # Exit on any error

echo "DataCenter AI Monitor - Quick Deployment"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}[ERROR] Docker Compose is not installed${NC}"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}[OK] Docker and Docker Compose detected${NC}"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}[WARN] .env file not found${NC}"
    echo "Creating example .env file..."
    cp .env.example .env 2>/dev/null || echo ".env.example not found"
    echo -e "${YELLOW}[WARN] Please edit the .env file and add your OPENAI_API_KEY${NC}"
    echo ""
fi

# Check if OPENAI_API_KEY is configured
if grep -q "your-openai-api-key-here" .env 2>/dev/null; then
    echo -e "${YELLOW}[WARN] You need to configure your OPENAI_API_KEY in the .env file${NC}"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi
fi

# Stop existing containers if any
echo "[INFO] Stopping existing containers (if any)..."
docker-compose down 2>/dev/null || true
echo ""

# Build and start containers
echo "[INFO] Building and starting containers..."
echo "This may take a few minutes the first time..."
echo ""

docker-compose up -d --build

# Wait for services to be ready
echo ""
echo "[INFO] Waiting for services to be ready..."
sleep 10

# Check container status
echo ""
echo "Service Status:"
docker-compose ps

# Check PostgreSQL health
echo ""
echo "[INFO] Verifying PostgreSQL..."
for i in {1..30}; do
    if docker-compose exec -T postgres pg_isready -U datacenter_user -d datacenter_db &> /dev/null; then
        echo -e "${GREEN}[OK] PostgreSQL is ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}[ERROR] PostgreSQL did not respond in time${NC}"
        echo "Check logs: docker-compose logs postgres"
        exit 1
    fi
    sleep 2
done

# Verify test data
echo ""
echo "[INFO] Verifying test data in database..."
METRICS_COUNT=$(docker-compose exec -T postgres psql -U datacenter_user -d datacenter_db -t -c "SELECT COUNT(*) FROM infrastructure_metrics;" 2>/dev/null | tr -d ' ')

if [ "$METRICS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}[OK] Database initialized with $METRICS_COUNT metrics${NC}"
else
    echo -e "${YELLOW}[WARN] No test data found${NC}"
fi

# Show access information
echo ""
echo "=============================================="
echo -e "${GREEN}Deployment completed successfully${NC}"
echo "=============================================="
echo ""
echo "Access URLs:"
echo ""
echo "  n8n (Automation):"
echo "     URL: http://localhost:5678"
echo "     User: admin"
echo "     Password: admin123"
echo ""
echo "  Dashboard (Streamlit):"
echo "     URL: http://localhost:8501"
echo ""
echo "  PostgreSQL:"
echo "     Host: localhost:5432"
echo "     Database: datacenter_db"
echo "     User: datacenter_user"
echo ""
echo "=============================================="
echo ""
echo "Next Steps:"
echo ""
echo "  1. Access n8n: http://localhost:5678"
echo "  2. Configure credentials (PostgreSQL and OpenAI)"
echo "  3. Import workflow: workflows/01-monitor.json"
echo "  4. Execute workflow to test"
echo "  5. Activate workflow for automatic monitoring"
echo ""
echo "For more information, see: DEPLOYMENT.md"
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f"
echo "  - Stop: docker-compose down"
echo "  - Restart: docker-compose restart"
echo ""
