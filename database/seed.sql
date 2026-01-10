-- DataCenter AI Monitor - Datos de Prueba

-- Métricas normales
INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status) VALUES
('SERVER-01', 'cpu', 45.2, 'normal'),
('SERVER-01', 'memory', 62.8, 'normal'),
('SERVER-01', 'disk', 55.0, 'normal'),
('SERVER-02', 'cpu', 38.5, 'normal'),
('SERVER-02', 'memory', 71.2, 'normal'),
('SERVER-03', 'cpu', 22.1, 'normal');

-- Métricas con warnings
INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status) VALUES
('SERVER-04', 'cpu', 85.5, 'warning'),
('SERVER-04', 'temperature', 68.2, 'warning'),
('SERVER-05', 'disk', 82.0, 'warning'),
('RACK-A05', 'temperature', 28.5, 'warning');

-- Métricas críticas (para trigger automático)
INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status) VALUES
('SERVER-06', 'temperature', 78.2, 'critical'),
('SERVER-07', 'disk', 95.0, 'critical'),
('SERVER-08', 'cpu', 98.5, 'critical'),
('RACK-A07', 'temperature', 35.5, 'critical'),
('UPS-01', 'battery', 15.0, 'critical');

-- Incidente de ejemplo (ya resuelto)
INSERT INTO incidents (device_id, severity, category, description, ai_analysis, status, auto_resolved, resolved_at, resolution_time)
VALUES 
('SERVER-09', 3, 'disk_space', 
 'Disco al 92% de capacidad',
 'Análisis: Crecimiento acelerado en últimas 6 horas. Probable acumulación de logs. Recomendación: Limpiar /var/log/ y revisar rotación de logs.',
 'resolved', true, NOW() - INTERVAL '2 hours', INTERVAL '15 minutes');

-- Predicción de ejemplo
INSERT INTO predictions (device_id, failure_type, probability, estimated_time_to_failure, confidence_score, recommended_actions)
VALUES
('SERVER-10', 'disk_full', 0.85, INTERVAL '48 hours', 0.92, 
 ARRAY['Expandir volumen', 'Limpiar archivos temporales', 'Configurar alertas tempranas']);

SELECT 'Datos de prueba insertados correctamente' as status;
SELECT COUNT(*) as total_metrics FROM infrastructure_metrics;
SELECT COUNT(*) as total_incidents FROM incidents;
SELECT COUNT(*) as total_predictions FROM predictions;
