# 🎬 AIOps Smart Incident Orchestrator - Video Demo Script

**Total Duration:** ~3 Minutes
**Audience:** Potential Clients (Fiverr/Upwork), Recruiters, or Technical Lead.

---

## 🕒 0:00 - 0:30 | Introduction & The Problem

**Visual:** Webcam + Landing page of the README.

- "Hi, I'm Daniel. Today I want to show you how we can solve one of the biggest headaches for DataCenter engineers: **Alert Fatigue**."
- "Traditional monitoring is too noisy. When a server spikes, engineers get buried in logs. This project, the **AIOps Smart Incident Orchestrator**, uses AI Agents to autonomously diagnose and remediate infrastructure issues."

## 🕒 0:30 - 1:15 | The Architecture (Layer by Layer)

**Visual:** Show the Mermaid diagram in the README.

- "The system works in four layers."
- "First, our **Ingestion Layer** collects real-time telemetry from servers and racks."
- "Second, the **n8n Orchestration Layer** processes these events. Instead of just sending an email, it queries a PostgreSQL database to understand the historical context."
- "Third—and this is the 'magic'—our **AI Agent Layer (GPT-4o)** performs a Root Cause Analysis. It looks at the logs and says: 'Hey, this isn't a hardware failure, it's a specific Java process causing a memory leak.'"

## 🕒 1:15 - 2:30 | Live Demo

**Visual:** Switch to the Streamlit Dashboard.

- "Let's see it in action in our Executive Dashboard."
- (Point to KPIs) "Here we see our real-time KPIs. Notice the **MTTR Reduction of 60%**—that's the ROI of using AI."
- (Filter for a server) "We can drill down into specific servers, like SERVER-09, to see its individual health."
- (Expand an AI Case) "When a critical incident occurs, like this temperature spike, look at the AI Deep Dive. The agent hasn't just identified the problem; it's provided a specific **Remediation Action**."

## 🕒 2:30 - 3:00 | Conclusion & Contact

**Visual:** Show the remediation button + GitHub repo.

- "This system doesn't just monitor; it thinks and acts. It drastically reduces downtime and allows your engineering team to focus on building, not just firefighting."
- "If you want to implement this level of automation in your infrastructure, let's talk. Thanks for watching!"

---

## 💡 Technical Setup for Recording

1. **Preparation**: Run `python scripts/generate_metrics.py` before starting to have fresh data.
2. **Tools**: Use OBS Studio or Loom for recording.
3. **Layout**: High-contrast dark mode (standard in the app) looks best on video.
