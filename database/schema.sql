-- DataCenter AI Monitor - Database Schema

-- Tabla principal de métricas
CREATE TABLE IF NOT EXISTS infrastructure_metrics (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    device_id VARCHAR(100) NOT NULL,
    metric_type VARCHAR(50) NOT NULL,
    metric_value NUMERIC NOT NULL,
    status VARCHAR(20) CHECK (status IN ('normal', 'warning', 'critical')),
    metadata JSONB,
    INDEX idx_device_status (device_id, status),
    INDEX idx_timestamp (timestamp DESC)
);

-- Tabla de incidentes
CREATE TABLE IF NOT EXISTS incidents (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    device_id VARCHAR(100) NOT NULL,
    severity INTEGER CHECK (severity BETWEEN 1 AND 5),
    category VARCHAR(50),
    description TEXT,
    ai_analysis TEXT,
    recommended_actions TEXT[],
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    resolution_time INTERVAL,
    resolved_at TIMESTAMPTZ,
    auto_resolved BOOLEAN DEFAULT false,
    INDEX idx_status (status),
    INDEX idx_device (device_id),
    INDEX idx_created (created_at DESC)
);

-- Tabla de predicciones
CREATE TABLE IF NOT EXISTS predictions (
    id SERIAL PRIMARY KEY,
    prediction_date TIMESTAMPTZ DEFAULT NOW(),
    device_id VARCHAR(100) NOT NULL,
    failure_type VARCHAR(100),
    probability DECIMAL(5,2),
    estimated_time_to_failure INTERVAL,
    confidence_score DECIMAL(3,2),
    recommended_actions TEXT[],
    INDEX idx_device_pred (device_id),
    INDEX idx_probability (probability DESC)
);

-- Tabla de acciones automatizadas
CREATE TABLE IF NOT EXISTS automated_actions (
    id SERIAL PRIMARY KEY,
    executed_at TIMESTAMPTZ DEFAULT NOW(),
    incident_id INTEGER REFERENCES incidents(id),
    action_type VARCHAR(50),
    action_details TEXT,
    success BOOLEAN,
    error_message TEXT
);

-- Vista analítica para dashboard
CREATE OR REPLACE VIEW incident_analytics AS
SELECT 
    DATE_TRUNC('hour', created_at) as hour,
    category,
    AVG(severity) as avg_severity,
    COUNT(*) as incident_count,
    COUNT(*) FILTER (WHERE auto_resolved = true) as auto_resolved_count,
    AVG(EXTRACT(EPOCH FROM resolution_time)) as avg_resolution_seconds
FROM incidents
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY hour, category
ORDER BY hour DESC;

COMMENT ON TABLE infrastructure_metrics IS 'Métricas en tiempo real de infraestructura del datacenter';
COMMENT ON TABLE incidents IS 'Incidentes detectados y su análisis con IA';
COMMENT ON TABLE predictions IS 'Predicciones de fallos basadas en tendencias';
