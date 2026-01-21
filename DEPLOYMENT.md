# 🚀 Guía de Despliegue Local - DataCenter AI Monitor

Esta guía te ayudará a desplegar el proyecto completo en tu máquina local usando Docker.

---

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener instalado:

- ✅ **Docker** (versión 20.10 o superior)
- ✅ **Docker Compose** (versión 2.0 o superior)
- ✅ **OpenAI API Key** (para el análisis con IA)

---

## 🔧 Paso 1: Configurar Variables de Entorno

1. Abre el archivo `.env` en la raíz del proyecto
2. Reemplaza los siguientes valores:

```bash
# OpenAI API Key (OBLIGATORIO)
OPENAI_API_KEY=sk-your-actual-openai-api-key-here

# Email para alertas (OPCIONAL - solo si usas el workflow de Gmail)
EMAIL_USER=tu-email@gmail.com
EMAIL_PASSWORD=tu-app-password-aqui
```

> **Nota**: Para obtener tu OpenAI API Key, visita: https://platform.openai.com/api-keys

---

## 🐳 Paso 2: Levantar los Contenedores

Ejecuta el siguiente comando en la raíz del proyecto:

```bash
docker-compose up -d
```

Este comando iniciará 3 servicios:
- **PostgreSQL** (puerto 5432) - Base de datos
- **n8n** (puerto 5678) - Plataforma de automatización
- **Streamlit Dashboard** (puerto 8501) - Dashboard ejecutivo

---

## ⏳ Paso 3: Verificar que los Servicios Estén Corriendo

Espera 30-60 segundos y verifica el estado:

```bash
docker-compose ps
```

Deberías ver algo como:

```
NAME                    STATUS              PORTS
datacenter-postgres     Up (healthy)        0.0.0.0:5432->5432/tcp
datacenter-n8n          Up                  0.0.0.0:5678->5678/tcp
datacenter-dashboard    Up                  0.0.0.0:8501->8501/tcp
```

---

## 🔑 Paso 4: Acceder a n8n

1. Abre tu navegador en: **http://localhost:5678**
2. Ingresa las credenciales:
   - **Usuario**: `admin`
   - **Contraseña**: `admin123`

---

## 📊 Paso 5: Importar los Workflows

### Opción A: Importar desde la interfaz de n8n

1. En n8n, haz clic en el botón **"+"** (arriba a la derecha)
2. Selecciona **"Import from File"**
3. Navega a la carpeta `workflows/` del proyecto
4. Importa los siguientes archivos:
   - `01-monitor.json` (Workflow principal de monitoreo)
   - `02-Gmail-Alert-Dispatcher.json` (Dispatcher de alertas - opcional)

### Opción B: Copiar workflows automáticamente (Recomendado)

Los workflows ya están montados en el contenedor. Solo necesitas:

1. Ir a n8n: http://localhost:5678
2. Crear un nuevo workflow
3. Hacer clic en el menú (⋮) → **"Import from File"**
4. Seleccionar `/workflows/01-monitor.json`

---

## 🔌 Paso 6: Configurar Credenciales en n8n

### 6.1 Configurar PostgreSQL

1. En n8n, ve a **Settings** → **Credentials**
2. Haz clic en **"+ Add Credential"**
3. Busca y selecciona **"Postgres"**
4. Ingresa los siguientes datos:

```
Name: DataCenter DB
Host: postgres
Database: datacenter_db
User: datacenter_user
Password: datacenter_pass_2024
Port: 5432
SSL: Disable
```

5. Haz clic en **"Save"**

### 6.2 Configurar OpenAI

1. En n8n, ve a **Settings** → **Credentials**
2. Haz clic en **"+ Add Credential"**
3. Busca y selecciona **"OpenAI"**
4. Ingresa tu API Key de OpenAI
5. Haz clic en **"Save"**

---

## ✅ Paso 7: Probar el Workflow

1. Abre el workflow **"DataCenter Monitor"**
2. Haz clic en el botón **"Execute Workflow"** (arriba a la derecha)
3. Deberías ver:
   - ✅ Consulta a PostgreSQL ejecutada
   - ✅ Filtrado de alertas críticas
   - ✅ Análisis de IA generado
   - ✅ Incidentes insertados en la base de datos

---

## 📈 Paso 8: Acceder al Dashboard

1. Abre tu navegador en: **http://localhost:8501**
2. Verás el dashboard ejecutivo con:
   - Métricas en tiempo real
   - Incidentes críticos
   - Análisis de tendencias

---

## 🔄 Paso 9: Activar el Monitoreo Automático

Para que el workflow se ejecute automáticamente cada 5 minutos:

1. En n8n, abre el workflow **"DataCenter Monitor"**
2. Haz clic en el botón **"Active"** (toggle en la esquina superior derecha)
3. El workflow ahora se ejecutará automáticamente según el Schedule Trigger

---

## 🛠️ Comandos Útiles

### Ver logs de los contenedores
```bash
# Todos los servicios
docker-compose logs -f

# Solo n8n
docker-compose logs -f n8n

# Solo PostgreSQL
docker-compose logs -f postgres

# Solo Dashboard
docker-compose logs -f dashboard
```

### Reiniciar servicios
```bash
# Reiniciar todo
docker-compose restart

# Reiniciar solo n8n
docker-compose restart n8n
```

### Detener servicios
```bash
docker-compose down
```

### Detener y eliminar volúmenes (⚠️ CUIDADO: Borra todos los datos)
```bash
docker-compose down -v
```

### Acceder a la base de datos directamente
```bash
docker exec -it datacenter-postgres psql -U datacenter_user -d datacenter_db
```

---

## 🐛 Solución de Problemas

### Problema: "Port 5432 already in use"
**Solución**: Ya tienes PostgreSQL corriendo localmente. Opciones:
1. Detén tu PostgreSQL local: `sudo systemctl stop postgresql`
2. Cambia el puerto en `docker-compose.yml`: `"5433:5432"`

### Problema: "Port 5678 already in use"
**Solución**: Ya tienes n8n corriendo. Opciones:
1. Detén n8n local
2. Cambia el puerto en `docker-compose.yml`: `"5679:5678"`

### Problema: "Cannot connect to database"
**Solución**:
1. Verifica que PostgreSQL esté healthy: `docker-compose ps`
2. Revisa los logs: `docker-compose logs postgres`
3. Reinicia los servicios: `docker-compose restart`

### Problema: "OpenAI API error"
**Solución**:
1. Verifica que tu API Key sea válida
2. Asegúrate de tener créditos en tu cuenta de OpenAI
3. Revisa que la credencial en n8n esté configurada correctamente

---

## 📊 Verificar que Todo Funciona

### 1. Base de Datos
```bash
docker exec -it datacenter-postgres psql -U datacenter_user -d datacenter_db -c "SELECT COUNT(*) FROM infrastructure_metrics;"
```

Deberías ver al menos 15 registros (datos de prueba).

### 2. n8n
Visita: http://localhost:5678 - Deberías ver la interfaz de login.

### 3. Dashboard
Visita: http://localhost:8501 - Deberías ver el dashboard con gráficas.

---

## 🎯 Próximos Pasos

1. **Personalizar el Workflow**: Ajusta los umbrales de alertas según tus necesidades
2. **Configurar Alertas por Email**: Importa el workflow `02-Gmail-Alert-Dispatcher.json`
3. **Agregar Más Métricas**: Ejecuta el script `scripts/generate_metrics.py` para generar datos sintéticos
4. **Explorar el Dashboard**: Analiza las tendencias y patrones de incidentes

---

## 📞 Soporte

Si encuentras algún problema:
1. Revisa los logs: `docker-compose logs -f`
2. Verifica que todos los servicios estén corriendo: `docker-compose ps`
3. Consulta la documentación oficial de n8n: https://docs.n8n.io

---

**¡Listo! Tu sistema AIOps está corriendo localmente. 🎉**

*Desarrollado por Daniel-jcVv | Powered by n8n, OpenAI & PostgreSQL*
