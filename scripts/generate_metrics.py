#!/usr/bin/env python3
"""
Script para generar métricas simuladas de datacenter
Útil para demos y testing
"""

import psycopg2
import random
from datetime import datetime, timedelta
import time
import os


# Configuración de conexión
DB_CONFIG = {
    'host': os.getenv('POSTGRE_HOST', 'localhost'),
    'port': os.getenv('POSTGRE_PORT'),
    'database': os.getenv('POSTGRE_DB'),
    'user': os.getenv('POSTGRE_USER'),
    'password': os.getenv('POSTGRE_PASSWORD')
}

# Dispositivos simulados
DEVICES = [
    'SERVER-01', 'SERVER-02', 'SERVER-03', 'SERVER-04', 'SERVER-05',
    'SERVER-06', 'SERVER-07', 'SERVER-08', 'SERVER-09', 'SERVER-10',
    'RACK-A01', 'RACK-A02', 'RACK-A03', 'RACK-A04', 'RACK-A05',
    'UPS-01', 'UPS-02', 'PDU-01', 'PDU-02', 'SWITCH-01'
]

# Tipos de métricas y sus rangos
METRICS = {
    'cpu': {'min': 10, 'max': 95, 'warning': 75, 'critical': 90},
    'memory': {'min': 30, 'max': 92, 'warning': 80, 'critical': 90},
    'disk': {'min': 20, 'max': 98, 'warning': 80, 'critical': 90},
    'temperature': {'min': 18, 'max': 40, 'warning': 28, 'critical': 32},
    'network': {'min': 5, 'max': 98, 'warning': 85, 'critical': 95},
}

def get_status(value, metric_config):
    """Determina status basado en umbrales"""
    if value >= metric_config['critical']:
        return 'critical'
    elif value >= metric_config['warning']:
        return 'warning'
    else:
        return 'normal'

def generate_metric():
    """Genera una métrica aleatoria"""
    device = random.choice(DEVICES)
    metric_type = random.choice(list(METRICS.keys()))
    config = METRICS[metric_type]
    
    # 70% normal, 20% warning, 10% critical
    rand = random.random()
    if rand < 0.70:
        value = random.uniform(config['min'], config['warning'] - 5)
    elif rand < 0.90:
        value = random.uniform(config['warning'], config['critical'] - 2)
    else:
        value = random.uniform(config['critical'], config['max'])
    
    value = round(value, 2)
    status = get_status(value, config)
    
    return {
        'device_id': device,
        'metric_type': metric_type,
        'metric_value': value,
        'status': status
    }

def insert_metrics(conn, num_metrics=50):
    """Inserta métricas en la base de datos"""
    cursor = conn.cursor()
    
    for _ in range(num_metrics):
        metric = generate_metric()
        
        query = """
        INSERT INTO infrastructure_metrics 
        (device_id, metric_type, metric_value, status)
        VALUES (%s, %s, %s, %s)
        """
        
        cursor.execute(query, (
            metric['device_id'],
            metric['metric_type'],
            metric['metric_value'],
            metric['status']
        ))
    
    conn.commit()
    cursor.close()
    
    print(f" {num_metrics} métricas insertadas correctamente")

def show_summary(conn):
    """Muestra resumen de métricas"""
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT status, COUNT(*) as count
        FROM infrastructure_metrics
        GROUP BY status
    """)
    
    print("\n Resumen de métricas:")
    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]}")
    
    cursor.close()

def main():
    """Función principal"""
    print(" Generador de Métricas - DataCenter AI Monitor\n")
    
    try:
        # Conectar a la base de datos
        conn = psycopg2.connect(**DB_CONFIG)
        print(" Conectado a PostgreSQL")
        
        # Generar métricas
        num = int(input("¿Cuántas métricas generar? (default: 50): ") or 50)
        insert_metrics(conn, num)
        
        # Mostrar resumen
        show_summary(conn)
        
        conn.close()
        print("\n Proceso completado")
        
    except Exception as e:
        print(f" Error: {e}")

if __name__ == "__main__":
    main()
