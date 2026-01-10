# Arquitectura del Sistema

## Visión General

DataCenter AI Monitor es un sistema de 3 capas que automatiza la detección, análisis y respuesta a incidentes en centros de datos.

## Diagrama de Flujo

```
┌──────────────────────────────────────────────┐
│         CAPA 1: INGESTA DE DATOS             │
│                                              │
│  [Métricas]  [Logs]  [Alertas]  [SNMP]     │
│      ↓          ↓        ↓         ↓        │
│           PostgreSQL (Time-series)           │
└──────────────┬───────────────────────────────┘
               │
┌──────────────▼───────────────────────────────┐
│         CAPA 2: PROCESAMIENTO (n8n)          │
│                                              │
│  Workflow 1: Monitor                         │
│  ┌─────────────────────────────────┐        │
│  │ Schedule → Query → Filter → AI  │        │
│  └─────────────────────────────────┘        │
│                                              │
│  Workflow 2: Predictor                       │
│  ┌─────────────────────────────────┐        │
│  │ Trigger → Analyze → Forecast    │        │
│  └─────────────────────────────────┘        │
│                                              │
│  Workflow 3: Auto-Remediation                │
│  ┌─────────────────────────────────┐        │
│  │ Event → Validate → Execute      │        │
│  └─────────────────────────────────┘        │
└──────────────┬───────────────────────────────┘
               │
┌──────────────▼───────────────────────────────┐
│         CAPA 3: ACCIÓN Y RESPUESTA           │
│                                              │
│  [Slack] [Email] [ServiceNow] [PagerDuty]  │
│  [Auto-fix] [Dashboard] [Knowledge Base]    │
└──────────────────────────────────────────────┘
```

## Componentes Detallados

### 1. Base de Datos (PostgreSQL)

**Tablas:**
- `infrastructure_metrics`: Métricas en tiempo real
- `incidents`: Incidentes detectados
- `predictions`: Análisis predictivo
- `automated_actions`: Registro de acciones

**Ventajas:**
- JSONB para flexibilidad
- Índices optimizados
- Time-series nativo
- ACID compliant

### 2. Motor de Workflows (n8n)

**Workflow 01: Monitor Principal**
```
Schedule (5 min) 
  → PostgreSQL (Query métricas críticas)
  → IF (¿Hay incidentes?)
  → OpenAI (Analizar contexto)
  → PostgreSQL (Guardar incidente + análisis)
  → Slack (Notificar equipo)
```

**Workflow 02: Predictor**
```
Webhook 
  → PostgreSQL (Historial 7 días)
  → Function (Calcular tendencias)
  → OpenAI (Predecir fallos)
  → PostgreSQL (Guardar predicción)
```

**Workflow 03: Auto-Remediation**
```
Database Trigger
  → Switch (Por tipo de incidente)
    ├─ Disco lleno → Script limpieza
    ├─ Temp alta → Ajustar HVAC  
    └─ Servicio caído → Restart
  → Validate (¿Funcionó?)
  → Update incident
```

### 3. Capa de IA

**OpenAI GPT-4o-mini**
- Clasificación de severidad
- Análisis de causa raíz
- Recomendaciones de acción
- Predicción de impacto

**Prompts optimizados:**
```
Rol: Experto en infraestructura de datacenter
Contexto: [métricas + historial]
Tarea: Análisis en 3 puntos:
  1. Severidad real (1-5)
  2. Causa probable
  3. Acción inmediata
```

## Flujo de Datos

1. **Ingesta** → Métricas cada 5 min
2. **Detección** → Umbral superado
3. **Enriquecimiento** → Buscar contexto
4. **Análisis IA** → Clasificar + recomendar
5. **Acción** → Alertar o auto-resolver
6. **Aprendizaje** → Retroalimentar modelo

## Escalabilidad

### Actual (Demo)
- 1 servidor n8n
- 1 PostgreSQL
- ~100 métricas/min

### Producción
- n8n cluster (Kubernetes)
- PostgreSQL HA (Patroni)
- Redis cache
- ~10K métricas/min

## Seguridad

- ✅ Credenciales en secrets
- ✅ API keys encriptadas
- ✅ RBAC en PostgreSQL
- ✅ Audit logs
- ✅ Network policies

## Monitoreo del Sistema

**Métricas clave:**
- Latencia de workflows
- Tasa de éxito IA
- False positive rate
- MTTR promedio
- Costo por incidente

## Integraciones Futuras

- DCIM (Sunbird, Nlyte)
- CMDB (ServiceNow)
- APM (Datadog, New Relic)
- Ticketing (Jira, PagerDuty)
- Chat (Slack, Teams)
