# 🤖 AIOps Smart Incident Orchestrator

<p align="center">
  <img src="https://raw.githubusercontent.com/Daniel-jcVv/DataCenter-AI-Monitor/main/docs/portfolio_hero.png" width="100%" alt="AIOps Cover">
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![n8n](https://img.shields.io/badge/n8n-Automation-FF6D5A?logo=n8n)](https://n8n.io)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o-412991?logo=openai)](https://openai.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)](https://www.postgresql.org)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![Streamlit](https://img.shields.io/badge/Streamlit-App-FF4B4B?logo=streamlit)](https://streamlit.io)

**An autonomous infrastructure health-monitoring and diagnostic system powered by AI Agents and n8n.**

---

## 🎬 Live System Demo
<p align="center">
  <video src="https://github.com/Daniel-jcVv/DataCenter-AI-Monitor/raw/main/docs/dashboard_demo.mp4" width="100%" controls autoplay loop muted></video>
</p>

---

## 🚀 The Business Problem
Modern Data Centers generate millions of logs and metrics every minute. Traditional "Threshold-based" monitoring results in **alert fatigue**.

**This solution solves this by:**
1. **Filtering Noise:** Only escalating truly critical events.
2. **Autonomous Diagnostics:** Using AI to perform Root Cause Analysis (RCA).
3. **MTTR Reduction:** Slashing resolution times by up to 60%.

---

## 🏗️ Solution Architecture
```mermaid
graph TD
    A[Telemetry Sources] -->|Webhooks| B(n8n Orchestrator)
    B -->|Query Context| C[(PostgreSQL Audit Log)]
    B -->|Analyze| D{AI Agent GPT-4o}
    D -->|RCA & Action| B
    B -->|Dispatch| E[Gmail Alerts]
    B -->|Update| C
    C -->|Real-time Feed| F[Streamlit Dashboard]
```

---

## 🖥️ Executive Dashboard
<p align="center">
  <img src="https://raw.githubusercontent.com/Daniel-jcVv/DataCenter-AI-Monitor/main/docs/monitor_aiops_system.png" width="100%" alt="Dashboard Preview">
</p>

---

## 📩 Contact & Collaboration
- **LinkedIn**: [daniel-garcía-belman-99a298aa](https://linkedin.com/in/daniel-garcía-belman-99a298aa)
- **Portfolio**: [danieljcvv-portfolio.vercel.app](https://danieljcvv-portfolio.vercel.app/)
- **Email**: [danielgb331@outlook.com](mailto:danielgb331@outlook.com)

---
*Developed by Daniel-jcVv | Powered by n8n, OpenAI & PostgreSQL*

**Soli Deo Gloria.**
