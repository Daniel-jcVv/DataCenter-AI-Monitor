#!/bin/bash
set -e

# Crear la base de datos de n8n si no existe
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE n8n_db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n_db')\gexec
EOSQL

echo "[OK] Base de datos n8n_db creada o ya existe"
