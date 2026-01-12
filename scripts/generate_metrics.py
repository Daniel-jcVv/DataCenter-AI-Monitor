#!/usr/bin/env python3
"""
Script para generar métricas e incidentes simulados de datacenter
Útil para demos y testing de dashboards
"""

import psycopg2
import random
from datetime import datetime, timedelta
import time
import os
import json

# Configuración de conexión
DB_CONFIG = {
    'host': os.getenv('POSTGRES_HOST', 'localhost'),
    'port': os.getenv('POSTGRES_PORT', '5435'), # Defaulting to exposed port
    'database': os.getenv('APP_DB_NAME', 'datacenter'),
    'user': os.getenv('POSTGRES_USER', 'n8n_user'),
    'password': os.getenv('POSTGRES_PASSWORD', 'n8n_password')
}

# Dispositivos simulados (Expanded)
DEVICES = [f'SERVER-{i:02d}' for i in range(1, 21)] + \
          [f'RACK-A{i:02d}' for i in range(1, 10)] + \
          ['UPS-01', 'UPS-02', 'PDU-main', 'PDU-backup', 'CORE-SWITCH-01', 'FIREWALL-01']

# Tipos de métricas
METRICS = {
    'cpu': {'min': 10, 'max': 99, 'warning': 80, 'critical': 95},
    'memory': {'min': 20, 'max': 98, 'warning': 85, 'critical': 92},
    'disk': {'min': 30, 'max': 99, 'warning': 85, 'critical': 95},
    'temperature': {'min': 18, 'max': 45, 'warning': 30, 'critical': 35},
    'network': {'min': 100, 'max': 10000, 'warning': 8000, 'critical': 9500}, # Mbps
    'power': {'min': 200, 'max': 1200, 'warning': 1000, 'critical': 1150} # Watts
}

AI_MOCK_ANALYSIS = [
    "Root cause identified: runaway process 'java_worker' consuming 98% CPU. Recommended: throttle or restart service.",
    "Potential memory leak detected in application layer. Swapping nearing capacity. Action: clear cache and monitor.",
    "Thermal anomaly detected in Rack A4. Airflow obstruction suspected. Check physical fans.",
    "Disk I/O latency spike due to backup job running during peak hours. Reschedule backup window.",
    "Packet loss detected on uplink. analyzing switch logs... Interface eth0 flapping."
]

def get_status(value, metric_config):
    if value >= metric_config['critical']:
        return 'critical'
    elif value >= metric_config['warning']:
        return 'warning'
    else:
        return 'normal'

def generate_metric(device=None, forced_status=None):
    device = device or random.choice(DEVICES)
    metric_type = random.choice(list(METRICS.keys()))
    config = METRICS[metric_type]
    
    if forced_status == 'critical':
        value = random.uniform(config['critical'], config['max'])
    elif forced_status == 'warning':
        value = random.uniform(config['warning'], config['critical'] - 0.1)
    else:
        # 80% normal
        value = random.uniform(config['min'], config['warning'] - 1)
    
    value = round(value, 2)
    status = get_status(value, config)
    
    return {
        'device_id': device,
        'metric_type': metric_type,
        'metric_value': value,
        'status': status
    }

def insert_data(conn, num_items=50):
    cursor = conn.cursor()
    
    # 1. Insert Metrics
    print(f"Generando {num_items} métricas...")
    for _ in range(num_items):
        m = generate_metric()
        cursor.execute("""
            INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status)
            VALUES (%s, %s, %s, %s)
        """, (m['device_id'], m['metric_type'], m['metric_value'], m['status']))
        
    # 2. Insert Simulated Incidents (for dashboard population)
    # Generate incidents for ~10% of metrics to simulate critical events
    num_incidents = max(1, int(num_items * 0.1))
    print(f"Generando {num_incidents} incidentes simulados...")
    
    for _ in range(num_incidents):
        device = random.choice(DEVICES)
        category = random.choice(list(METRICS.keys()))
        severity = random.randint(3, 5)
        analysis = random.choice(AI_MOCK_ANALYSIS)
        
        # Simulate text from AI
        ai_json = json.dumps({
            "id": f"msg_{random.randint(1000,9999)}",
            "content": [{"text": analysis}]
        })
        
        cursor.execute("""
            INSERT INTO incidents (device_id, category, severity, description, status, ai_analysis, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, NOW() - (random() * interval '24 hours'))
        """, (
            device,
            category,
            severity,
            f"Automated Alert: {category} threshold exceeded on {device}",
            random.choice(['open', 'resolved', 'in_progress']),
            ai_json
        ))
    
    conn.commit()
    cursor.close()
    print("Datos insertados correctamente.")

def main():
    print("--- DataCenter Traffic Simulator ---")
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("Conectado a DB.")
        
        insert_data(conn, num_items=100)
        
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
