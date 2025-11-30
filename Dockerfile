# Multi-stage Dockerfile for ADK-Powered Travel Planner
# Supports running all agents and UI in a single container (for Cloud Run)

FROM python:3.11-slim as base

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY agents/ ./agents/
COPY common/ ./common/
COPY shared/ ./shared/
COPY travel_ui.py .
COPY start_all.ps1 .

# Create a simple start script for Cloud Run
RUN echo '#!/bin/bash\n\
# Start all agents in background\n\
uvicorn agents.host_agent.__main__:app --host 0.0.0.0 --port 8000 &\n\
uvicorn agents.flight_agent.__main__:app --host 0.0.0.0 --port 8001 &\n\
uvicorn agents.stay_agent.__main__:app --host 0.0.0.0 --port 8002 &\n\
uvicorn agents.activities_agent.__main__:app --host 0.0.0.0 --port 8003 &\n\
uvicorn agents.calendar_agent.__main__:app --host 0.0.0.0 --port 8004 &\n\
# Start Streamlit UI in foreground\n\
streamlit run travel_ui.py --server.port 8501 --server.address 0.0.0.0\n\
' > /app/start.sh && chmod +x /app/start.sh

# Expose all necessary ports
EXPOSE 8000 8001 8002 8003 8004 8501

# Environment variables
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/')"

# Start all services
CMD ["/app/start.sh"]
