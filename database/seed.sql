-- DataCenter AI Monitor - Test Data
-- Normal metrics
INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status)
VALUES ('SERVER-01', 'cpu', 45.2, 'normal'),
    ('SERVER-01', 'memory', 62.8, 'normal'),
    ('SERVER-01', 'disk', 55.0, 'normal'),
    ('SERVER-02', 'cpu', 38.5, 'normal'),
    ('SERVER-02', 'memory', 71.2, 'normal'),
    ('SERVER-03', 'cpu', 22.1, 'normal');
-- Warning metrics
INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status)
VALUES ('SERVER-04', 'cpu', 85.5, 'warning'),
    ('SERVER-04', 'temperature', 68.2, 'warning'),
    ('SERVER-05', 'disk', 82.0, 'warning'),
    ('RACK-A05', 'temperature', 28.5, 'warning');
-- Critical metrics (for automatic trigger)
INSERT INTO infrastructure_metrics (device_id, metric_type, metric_value, status)
VALUES ('SERVER-06', 'temperature', 78.2, 'critical'),
    ('SERVER-07', 'disk', 95.0, 'critical'),
    ('SERVER-08', 'cpu', 98.5, 'critical'),
    ('RACK-A07', 'temperature', 35.5, 'critical'),
    ('UPS-01', 'battery', 15.0, 'critical');
-- Example incident (already resolved)
INSERT INTO incidents (
        device_id,
        severity,
        category,
        description,
        ai_analysis,
        status,
        auto_resolved,
        resolved_at,
        resolution_time
    )
VALUES (
        'SERVER-09',
        3,
        'disk_space',
        'Disk at 92% capacity',
        'Analysis: Accelerated growth in last 6 hours. Probable log accumulation. Recommendation: Clean /var/log/ and review log rotation.',
        'resolved',
        true,
        NOW() - INTERVAL '2 hours',
        INTERVAL '15 minutes'
    );
-- Example prediction
INSERT INTO predictions (
        device_id,
        failure_type,
        probability,
        estimated_time_to_failure,
        confidence_score,
        recommended_actions
    )
VALUES (
        'SERVER-10',
        'disk_full',
        0.85,
        INTERVAL '48 hours',
        0.92,
        ARRAY ['Expand volume', 'Clean temporary files', 'Configure early alerts']
    );
SELECT 'Test data inserted successfully' as status;
SELECT COUNT(*) as total_metrics
FROM infrastructure_metrics;
SELECT COUNT(*) as total_incidents
FROM incidents;
SELECT COUNT(*) as total_predictions
FROM predictions;