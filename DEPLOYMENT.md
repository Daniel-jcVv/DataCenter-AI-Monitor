# 🚀 Local Deployment Guide - DataCenter AI Monitor

This guide will help you deploy the complete project on your local machine using Docker.

---

## 📋 Prerequisites

Before starting, make sure you have installed:

- ✅ **Docker** (version 20.10 or higher)
- ✅ **Docker Compose** (version 2.0 or higher)
- ✅ **OpenAI API Key** (for AI analysis)

---

## 🔧 Step 1: Configure Environment Variables

1. Open the `.env` file in the project root
2. Replace the following values:

```bash
# OpenAI API Key (REQUIRED)
OPENAI_API_KEY=sk-your-actual-openai-api-key-here

# Email for alerts (OPTIONAL - only if using Gmail workflow)
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password-here
```

> **Note**: To get your OpenAI API Key, visit: <https://platform.openai.com/api-keys>

---

## 🐳 Step 2: Start the Containers

Run the following command in the project root:

```bash
docker-compose up -d
```

This command will start 3 services:

- **PostgreSQL** (port 5432) - Database
- **n8n** (port 5678) - Automation platform
- **Streamlit Dashboard** (port 8501) - Executive dashboard

---

## ⏳ Step 3: Verify Services are Running

Wait 30-60 seconds and check the status:

```bash
docker-compose ps
```

You should see something like:

```text
NAME                    STATUS              PORTS
datacenter-postgres     Up (healthy)        0.0.0.0:5432->5432/tcp
datacenter-n8n          Up                  0.0.0.0:5678->5678/tcp
datacenter-dashboard    Up                  0.0.0.0:8501->8501/tcp
```

---

## 🔑 Step 4: Access n8n

1. Open your browser at: **<http://localhost:5678>**
2. Enter credentials:
   - **User**: `admin`
   - **Password**: `admin123`

---

## 📊 Step 5: Import Workflows

### Option A: Import from n8n interface

1. In n8n, click the **"+"** button (top right)
2. Select **"Import from File"**
3. Navigate to the project's `workflows/` folder
4. Import the following files:
   - `01-monitor.json` (Main monitoring workflow)
   - `02-Gmail-Alert-Dispatcher.json` (Alert dispatcher - optional)

### Option B: Copy workflows automatically (Recommended)

The workflows are already mounted in the container. You just need to:

1. Go to n8n: <http://localhost:5678>
2. Create a new workflow
3. Click the menu (⋮) → **"Import from File"**
4. Select `/workflows/01-monitor.json`

---

## 🔌 Step 6: Configure Credentials in n8n

### 6.1 Configure PostgreSQL

1. In n8n, go to **Settings** → **Credentials**
2. Click **"+ Add Credential"**
3. Search and select **"Postgres"**
4. Enter the following data:

```text
Name: DataCenter DB
Host: postgres
Database: datacenter_db
User: datacenter_user
Password: datacenter_pass_2024
Port: 5432
SSL: Disable
```

5. Click **"Save"**

### 6.2 Configure OpenAI

1. In n8n, go to **Settings** → **Credentials**
2. Click **"+ Add Credential"**
3. Search and select **"OpenAI"**
4. Enter your OpenAI API Key
5. Click **"Save"**

---

## ✅ Step 7: Test the Workflow

1. Open the **"DataCenter Monitor"** workflow
2. Click the **"Execute Workflow"** button (top right)
3. You should see:
   - ✅ PostgreSQL query executed
   - ✅ Critical alerts filtered
   - ✅ AI analysis generated
   - ✅ Incidents inserted into database

---

## 📈 Step 8: Access the Dashboard

1. Open your browser at: **<http://localhost:8501>**
2. You'll see the executive dashboard with:
   - Real-time metrics
   - Critical incidents
   - Trend analysis

---

## 🔄 Step 9: Activate Automatic Monitoring

To have the workflow run automatically every 5 minutes:

1. In n8n, open the **"DataCenter Monitor"** workflow
2. Click the **"Active"** button (toggle in top right corner)
3. The workflow will now run automatically according to the Schedule Trigger

---

## 🛠️ Useful Commands

### View container logs

```bash
# All services
docker-compose logs -f

# Only n8n
docker-compose logs -f n8n

# Only PostgreSQL
docker-compose logs -f postgres

# Only Dashboard
docker-compose logs -f dashboard
```

### Restart services

```bash
# Restart all
docker-compose restart

# Restart only n8n
docker-compose restart n8n
```

### Stop services

```bash
docker-compose down
```

### Stop and remove volumes (⚠️ WARNING: Deletes all data)

```bash
docker-compose down -v
```

### Access database directly

```bash
docker exec -it datacenter-postgres psql -U datacenter_user -d datacenter_db
```

---

## 🐛 Troubleshooting

### Problem: "Port 5432 already in use"

**Solution**: You already have PostgreSQL running locally. Options:

1. Stop your local PostgreSQL: `sudo systemctl stop postgresql`
2. Change port in `docker-compose.yml`: `"5433:5432"`

### Problem: "Port 5678 already in use"

**Solution**: You already have n8n running. Options:

1. Stop local n8n
2. Change port in `docker-compose.yml`: `"5679:5678"`

### Problem: "Cannot connect to database"

**Solution**:

1. Verify PostgreSQL is healthy: `docker-compose ps`
2. Check logs: `docker-compose logs postgres`
3. Restart services: `docker-compose restart`

### Problem: "OpenAI API error"

**Solution**:

1. Verify your API Key is valid
2. Make sure you have credits in your OpenAI account
3. Check that the credential in n8n is configured correctly

---

## 📊 Verify Everything Works

### 1. Database

```bash
docker exec -it datacenter-postgres psql -U datacenter_user -d datacenter_db -c "SELECT COUNT(*) FROM infrastructure_metrics;"
```

You should see at least 15 records (test data).

### 2. n8n

Visit: <http://localhost:5678> - You should see the login interface.

### 3. Dashboard

Visit: <http://localhost:8501> - You should see the dashboard with charts.

---

## 🎯 Next Steps

1. **Customize the Workflow**: Adjust alert thresholds according to your needs
2. **Configure Email Alerts**: Import the `02-Gmail-Alert-Dispatcher.json` workflow
3. **Add More Metrics**: Run the `scripts/generate_metrics.py` script to generate synthetic data
4. **Explore the Dashboard**: Analyze trends and incident patterns

---

## 📞 Support

If you encounter any problems:

1. Check logs: `docker-compose logs -f`
2. Verify all services are running: `docker-compose ps`
3. Consult official n8n documentation: <https://docs.n8n.io>

---

**Ready! Your AIOps system is running locally. 🎉**

*Developed by Daniel-jcVv | Powered by n8n, OpenAI & PostgreSQL*
