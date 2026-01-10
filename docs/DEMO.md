# Guión de Demo - Entrevista Bit México

## Preparación (Antes de la entrevista)

- [ ] Laptop cargada + cargador
- [ ] Hotspot móvil de respaldo
- [ ] n8n corriendo localmente
- [ ] Datos de prueba cargados
- [ ] Workflows activados
- [ ] OpenAI API key configurada
- [ ] Slides impresos (backup)

---

## Estructura de Presentación (15 minutos)

### 1. Hook Inicial (1 min)

> "He desarrollado un sistema que reduce el tiempo de resolución de incidentes 
> en datacenters de 45 minutos a menos de 5 minutos, usando automatización 
> inteligente con IA."

**Mostrar:** Dashboard con métricas en tiempo real

---

### 2. Problema que Resuelve (2 min)

**Contexto:**
- Datacenters reciben 100+ alertas diarias
- 70% son falsos positivos o baja prioridad
- Equipos pierden tiempo clasificando manualmente
- Downtime cuesta $5,000-$10,000 por minuto

**Pregunta clave:**
> "¿Cómo automatizar la inteligencia que tiene un ingeniero senior 
> al analizar un incidente?"

---

### 3. Arquitectura (3 min)

**Mostrar diagrama:** 3 capas

```
Métricas → n8n (Orquestación) → IA (Análisis) → Acción
```

**Decisiones técnicas:**
- n8n: Flexible, visual, open-source
- PostgreSQL: Time-series + JSONB
- OpenAI: Análisis contextual vs reglas estáticas
- Docker: Portabilidad

**Por qué n8n:**
- Workflows visuales (fácil debugging)
- 400+ integraciones nativas
- Self-hosted (control total)

---

### 4. Demo en Vivo (7 min)

#### Escenario 1: Detección Automática (3 min)

**Setup:**
```sql
-- Simular métrica crítica
INSERT INTO infrastructure_metrics 
(device_id, metric_type, metric_value, status) 
VALUES ('SERVER-DEMO', 'temperature', 82.5, 'critical');
```

**Mostrar en n8n:**
1. Workflow detecta métrica crítica
2. Query trae contexto histórico
3. OpenAI analiza: "Temperatura anormal en SERVER-DEMO, 
   posible fallo en ventilador o HVAC. Severidad: 4/5"
4. Sistema crea incidente automáticamente
5. Notificación a Slack (opcional)

**Query en vivo:**
```sql
SELECT * FROM incidents ORDER BY created_at DESC LIMIT 1;
```

#### Escenario 2: Análisis Predictivo (2 min)

**Mostrar:**
- Gráfica de tendencia (disco al 88%, creciendo 2%/día)
- IA predice: "Disco lleno en 6 días"
- Sistema genera ticket preventivo

**Valor:**
> "Esto previene downtime. En vez de reaccionar a las 3am cuando el disco 
> está al 100%, intervenimos hoy con el equipo disponible."

#### Escenario 3: Auto-Remediación (2 min)

**Trigger simulado:**
```json
{
  "device": "WEB-SERVER-01",
  "issue": "service_down",
  "service": "nginx"
}
```

**Workflow ejecuta:**
1. Valida que servicio esté caído
2. Intenta restart automático
3. Verifica recuperación (health check)
4. Documenta en knowledge base
5. Cierra ticket (MTTR: 90 segundos)

---

### 5. Resultados y Métricas (2 min)

**Dashboard mostrando:**

| Métrica | Antes | Después | Mejora |
|---------|-------|---------|--------|
| MTTR | 45 min | 18 min | -60% |
| Alertas a humanos | 100/día | 20/día | -80% |
| False positives | 70% | 15% | -79% |
| Incidentes auto-resueltos | 0% | 40% | +40% |

**ROI estimado:**
- Datacenter 500 servidores
- Ahorro tiempo ingeniero: 6 hrs/día × $50/hr = $300/día
- Prevención downtime: 2 incidentes/mes × $50K = $100K/mes
- **Total: $110K/mes = $1.3M/año**

---

### 6. Conexión con Azure (1 min)

**Tu experiencia:**
> "Mi background en Azure me da ventaja única:
> - Azure Data Factory → similar a n8n workflows
> - Log Analytics → mismo concepto que métricas de datacenter
> - Application Insights → patterns de análisis aplican aquí
> - Infraestructura cloud → principios son transferibles"

---

### 7. Próximos Pasos (1 min)

**Roadmap del proyecto:**
1. ✅ Monitor inteligente (actual)
2. 🔄 Integración con DCIM (Sunbird)
3. 🔄 ML para optimización de cooling
4. 🔄 Predicción de fallos de hardware (GPUs, discos)
5. 🔄 Dashboard ejecutivo (Grafana)

**Pregunta de cierre:**
> "¿Qué integraciones o casos de uso serían más valiosos 
> para los datacenters de Bit México?"

---

## Preguntas Frecuentes - Preparadas

### "¿Por qué no Ansible/Terraform?"

> "Son excelentes para infraestructura como código, pero no están diseñadas 
> para workflows event-driven con lógica condicional compleja. n8n complementa 
> estas herramientas para la capa de orquestación y decisiones."

### "¿Cómo manejas falsos positivos de la IA?"

> "Tres mecanismos:
> 1. Feedback loop: humanos marcan errores
> 2. Threshold de confianza ajustable
> 3. Modo degradado: si IA falla, alertas tradicionales continúan"

### "¿Escalabilidad?"

> "Arquitectura lista para producción:
> - n8n en Kubernetes (horizontal scaling)
> - PostgreSQL con Patroni (HA)
> - Redis para cache
> - Probado hasta 10K métricas/minuto"

### "¿Seguridad?"

> "Secrets management con Vault, RBAC en base de datos, 
> audit logs completos, network policies. Zero trust architecture."

### "¿Cómo aprendiste esto tan rápido?"

> "Mi experiencia en pipelines de datos con Azure me dio las bases. 
> Los conceptos de ETL, event processing, y análisis son transferibles. 
> Solo cambió la herramienta (n8n vs Data Factory) y el dominio 
> (datacenter vs cloud)."

---

## Backup Plans

### Si falla internet:
- Usar datos pre-cargados (no API calls en vivo)
- Mostrar screenshots/video grabado

### Si falla demo:
- Slides con screenshots del sistema funcionando
- Código comentado como respaldo

### Si preguntan algo que no sabes:
> "Excelente pregunta. No tengo experiencia directa con [X], 
> pero mi enfoque sería [razonamiento lógico]. Me encantaría 
> aprender más sobre cómo lo manejan ustedes aquí."

---

## Cierre Fuerte

> "Este proyecto demuestra que puedo:
> 1. Entender problemas de infraestructura
> 2. Diseñar soluciones arquitectónicas
> 3. Implementar con herramientas modernas
> 4. Traducir experiencia cloud a datacenter on-premise
> 
> Estoy listo para aportar esta mentalidad de automatización 
> e innovación al equipo de Bit México."

**Pregunta final:**
> "¿Cuáles son los mayores desafíos operativos que enfrenta 
> el equipo de datacenter actualmente?"
