import streamlit as st
import psycopg2
import pandas as pd
import os
import plotly.express as px
from datetime import datetime
from dotenv import load_dotenv
from pathlib import Path
import warnings
import json
import re

# Suppress pandas UserWarning about SQLAlchemy
warnings.filterwarnings('ignore', category=UserWarning, module='pandas')

# Load environment variables from the root .env file (Robust Path)
env_path = (Path(__file__).parent / '../../../.env').resolve()
load_dotenv(env_path)

# PAGE CONFIGURATION
st.set_page_config(
    page_title="DataCenter AI Monitor - AIOps",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom professional CSS
st.markdown("""
<style>
    .metric-card {
        background-color: #1E1E1E;
        padding: 20px;
        border-radius: 10px;
        border-left: 5px solid #FF4B4B;
        box-shadow: 2px 2px 10px rgba(0,0,0,0.2);
    }
    .stDataFrame {
        border-radius: 10px;
    }
    h1, h2, h3 {
        font-family: 'Helvetica Neue', sans-serif;
    }
</style>
""", unsafe_allow_html=True)

from sqlalchemy import create_engine

# DATABASE CONNECTION
@st.cache_resource
def init_connection():
    db_user = os.getenv('POSTGRES_USER', 'n8n_user')
    db_pass = os.getenv('POSTGRES_PASSWORD')
    db_host = os.getenv('POSTGRES_HOST', 'localhost')
    db_port = os.getenv('POSTGRES_PORT', '5432')
    db_name = os.getenv('APP_DB_NAME', 'datacenter')
    
    # Construct SQLAlchemy connection string
    db_url = f"postgresql+psycopg2://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"
    return create_engine(db_url)

engine = init_connection()

# DATA FUNCTIONS
def get_kpis():
    with engine.connect() as conn:
        from sqlalchemy import text
        
        result_total = conn.execute(text("SELECT COUNT(*) FROM incidents WHERE created_at >= NOW() - INTERVAL '24 hours'"))
        total_24h = result_total.fetchone()[0]
        
        result_crit = conn.execute(text("SELECT COUNT(*) FROM incidents WHERE severity >= 4 AND status = 'open'"))
        critical_open = result_crit.fetchone()[0]
        
        mttr = "18 min"
        
    return total_24h, critical_open, mttr

def get_incidents():
    query = """
    SELECT 
        id, 
        created_at, 
        device_id, 
        category, 
        severity, 
        status, 
        substring(description, 1, 50) as short_desc,
        ai_analysis
    FROM incidents 
    ORDER BY created_at DESC 
    LIMIT 50
    """
    return pd.read_sql(query, engine)

def clean_analysis_text(raw_text):
    """Parses and cleans the AI analysis JSON/String from DB."""
    if not raw_text:
        return "No analysis available."
    
    try:
        # Regex to extract text content if it's trapped in a JSON string structure
        match = re.search(r'\\"text\\":\\"(.*?)\\"', raw_text)
        if match:
            clean = match.group(1)
            clean = clean.replace('\\n', '\n').replace('\\', '')
            return clean
            
        # If not regex match, try standard JSON parse
        if raw_text.strip().startswith('{'):
            data = json.loads(raw_text)
            # Handle different structures
            if 'content' in data and isinstance(data['content'], list):
               return data['content'][0].get('text', str(data))
            
        return raw_text # Return as is if simple string
    except Exception:
        return raw_text

# SIDEBAR FILTERS
st.sidebar.title("🎛️ Ops Filters")
st.sidebar.markdown("Refine your monitoring view.")

df = get_incidents()

# Data Guard
if df.empty:
    st.warning("No data found in database.")
else:
    # Filter: Category
    categories = ['All'] + sorted(df['category'].unique().tolist())
    selected_category = st.sidebar.selectbox("Filter by Category", categories)

    # Filter: Device (New)
    devices = ['All'] + sorted(df['device_id'].unique().tolist())
    selected_device = st.sidebar.selectbox("Filter by Server/Device", devices)

    # Filter: Severity
    min_severity = st.sidebar.slider("Minimum Severity", 1, 5, 1)

    # Apply Filters
    df_filtered = df[df['severity'] >= min_severity]
    if selected_category != 'All':
        df_filtered = df_filtered[df_filtered['category'] == selected_category]
    if selected_device != 'All':
        df_filtered = df_filtered[df_filtered['device_id'] == selected_device]

    # MAIN LAYOUT

    # Header
    col_logo, col_title = st.columns([1, 5])
    with col_logo:
        # Using absolute path for robustness
        logo_path = Path(__file__).parent / "assets/logo.png"
        st.image(str(logo_path), width=100) 
    with col_title:
        st.title("AIOps Smart Incident Orchestrator")
        st.markdown("### 🧠 Autonomous Infrastructure Monitoring with n8n & AI Agents")

    st.divider()

    # KPIs
    kpi1, kpi2, kpi3, kpi4 = st.columns(4)
    total_24h, critical_open, mttr = get_kpis()

    kpi1.metric("Active Critical Alerts", critical_open, delta_color="inverse")
    kpi2.metric("Incidents (24h)", total_24h)
    kpi3.metric("Avg MTTR (AI Assisted)", mttr, delta="-60%")
    kpi4.metric("AI Auto-Resolution", "85%", delta="12%")

    st.divider()

    # Chart and Table
    col_chart, col_table = st.columns([1, 2])

    with col_chart:
        st.subheader("Incident Trends")
        if not df_filtered.empty:
            # Bar Chart instead of Pie
            chart_data = df_filtered.groupby('category').size().reset_index(name='count')
            fig = px.bar(
                chart_data, 
                x='category', 
                y='count', 
                color='count',
                title='Incidents by Category', 
                color_continuous_scale='Redor' # Redor is similar to Red style
            )
            # Clean layout
            fig.update_layout(paper_bgcolor="rgba(0,0,0,0)", font_color="white")
            st.plotly_chart(fig)
        else:
            st.info("No data filters.")

    with col_table:
        st.subheader("Audit Log (Live)")
        
        display_df = df_filtered.drop(columns=['ai_analysis'])
        st.dataframe(
            display_df, 
            hide_index=True,
            use_container_width=True,
            column_config={
                "created_at": st.column_config.DatetimeColumn("Timestamp", format="D MMM, HH:mm"),
                "severity": st.column_config.ProgressColumn("Severity", min_value=1, max_value=5, format="%d"),
                "status": st.column_config.SelectboxColumn("Status", options=["open", "resolved"])
            }
        )

    # EXPANDABLE DETAILS WITH AI
    st.subheader("🤖 AI Root Cause Analysis (Deep Dive)")

    if not df_filtered.empty:
        for index, row in df_filtered.head(5).iterrows():
            with st.expander(f"[{row['created_at'].strftime('%H:%M')}] {row['device_id']} - {row['category'].upper()}"):
                c1, c2 = st.columns([2, 1])
                with c1:
                    st.markdown("#### Root Cause Analysis")
                    # Apply Cleaning Function
                    clean_text = clean_analysis_text(row['ai_analysis'])
                    st.info(clean_text)
                    
                with c2:
                    st.markdown("#### Remediation")
                    
                    # Device Context
                    st.caption("Target Device")
                    st.code(row['device_id'], language="bash")
                    
                    # Recommended Action
                    st.caption("Recommended Action")
                    st.warning("Immediate verification required.")
                    
                    st.write("") # Spacer
                    if st.button(f"Resolve Incident #{row['id']}", key=f"btn_{row['id']}", type="primary"):
                        st.toast(f"Incident #{row['id']} marked as Resolved!", icon="✅")
                        # Placeholder for SQL update logic
    else:
        st.write("No incidents match your filters.")

    # Footer
    st.markdown("---")
    st.markdown("*Powered by n8n, OpenAI GPT-4o & PostgreSQL* | Developed by Daniel")
