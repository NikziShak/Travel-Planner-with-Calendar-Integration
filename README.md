# ADK-Powered Travel Planner 🌍🛫

This project is a multi-agent AI-powered travel planner built using Google's Agent Development Kit (ADK). It showcases how intelligent agents can coordinate to plan a complete trip: flights, stays, and activities. A simple Streamlit UI wraps everything for an intuitive end-user experience.

## 📚 What is ADK?

ADK (Agent Development Kit) is Google's open-source framework designed to help developers build modular, production-ready multi-agent systems powered by LLMs. It supports:

Hierarchical, parallel, or sequential agent orchestration

Integration with models via LiteLLM: GPT-4o, Claude, Gemini, Mistral, etc.

Streaming conversations, callbacks, session memory

Deployment in any environment (local, container, or cloud)

Each agent in ADK is self-contained, exposing a /run endpoint and metadata for discovery using the A2A (Agent-to-Agent) protocol.

## 🎨 Project Overview

This travel planner demonstrates a modular, orchestrated agent workflow:

User Input → Streamlit UI → Host Agent → [Flight Agent, Stay Agent, Activities Agent]

host_agent: Coordinates the planning process

flight_agent: Suggests flights

stay_agent: Recommends hotels

activities_agent: Suggests local experiences

Agents communicate over REST using FastAPI and respond with structured JSON outputs.

## 📂 Project Structure

ADK_demo/

├── agents/

│   ├── host_agent/

│   ├── flight_agent/

│   ├── stay_agent/

│   └── activities_agent/

├── shared/           # Shared Pydantic models

├── common/           # A2A client/server logic

├── streamlit_app.py  # UI

├── requirements.txt

└── README.md

## 🚀 Getting Started

1. Clone the Repo
```
git clone https://github.com/NikitSharma/Google-Agent-Development-Kit-Demo.git
cd Google-Agent-Development-Kit-Demo
```
2. Setup Environment
3. 
```
python3 -m venv adk_demo
source adk_demo/bin/activate
pip install -r requirements.txt
```

Add your Gemini API key:

```
export GEMINI_API_KEY="your-api-key"
```
## 🔄 Run the Agents and UI

Start each agent using the following commands in terminal :

```
uvicorn agents.host_agent.__main__:app --port 8000 &
uvicorn agents.flight_agent.__main__:app --port 8001 &
uvicorn agents.stay_agent.__main__:app --port 8002 &
uvicorn agents.activities_agent.__main__:app --port 8003 &
uvicorn agents.calendar_agent.__main__:app --port 8004 &
```

Launch the frontend:

```
streamlit run travel_ui.py
```

## 📅 Google Calendar Integration (Optional)

The travel planner can automatically add your travel plans to Google Calendar! This feature is optional and requires some setup.

### Setup Google Calendar API

1. **Create a Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one

2. **Enable Google Calendar API**
   - In your project, go to "APIs & Services" > "Library"
   - Search for "Google Calendar API"
   - Click "Enable"

3. **Create OAuth 2.0 Credentials**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Choose "Desktop app" as the application type
   - Download the credentials JSON file
   - Rename it to `credentials.json` and place it in the project root directory

4. **First-Time Authentication**
   - When you first use the calendar feature, your browser will open for OAuth authentication
   - Sign in with your Google account and grant calendar access
   - A `token.pickle` file will be created for future use

### Using Calendar Integration

1. Check the "📅 Add to Google Calendar" checkbox in the UI
2. Submit your travel plan
3. The system will automatically create calendar events for:
   - Flight departures and arrivals
   - Hotel check-in and check-out
   - Scheduled activities
4. View your events directly in Google Calendar with clickable links!

### Troubleshooting

- **Credentials not found**: Make sure `credentials.json` is in the project root
- **Authentication error**: Delete `token.pickle` and re-authenticate
- **Events not created**: Check that the calendar agent is running on port 8004

## ☁️ Cloud Deployment

### Deploy to Google Cloud Run

The application is fully containerized and ready to deploy to Google Cloud Run. This allows you to run the service in the cloud with automatic scaling.

#### Prerequisites

1. **Google Cloud Account** with billing enabled
2. **gcloud CLI** installed and configured
   ```bash
   # Install: https://cloud.google.com/sdk/docs/install
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```
3. **Docker** installed locally
4. **GEMINI_API_KEY** environment variable set

#### Quick Deploy (Windows)

```powershell
# Set your Gemini API key
$env:GEMINI_API_KEY = "your-api-key-here"

# Run the deployment script
.\deploy-cloud-run.ps1
```

#### Quick Deploy (Linux/Mac)

```bash
# Set your Gemini API key
export GEMINI_API_KEY="your-api-key-here"

# Make script executable and run
chmod +x deploy-cloud-run.sh
./deploy-cloud-run.sh
```

#### Manual Deployment Steps

1. **Build the Docker image**:
   ```bash
   docker build -t gcr.io/YOUR_PROJECT_ID/adk-travel-planner:latest .
   ```

2. **Push to Google Container Registry**:
   ```bash
   gcloud auth configure-docker
   docker push gcr.io/YOUR_PROJECT_ID/adk-travel-planner:latest
   ```

3. **Deploy to Cloud Run**:
   ```bash
   gcloud run deploy adk-travel-planner \
     --image=gcr.io/YOUR_PROJECT_ID/adk-travel-planner:latest \
     --platform=managed \
     --region=us-central1 \
     --allow-unauthenticated \
     --port=8501 \
     --memory=2Gi \
     --cpu=2 \
     --set-env-vars="GEMINI_API_KEY=your-api-key"
   ```

4. **Access your deployed app**:
   The command will output a URL like: `https://adk-travel-planner-xxxxx.run.app`

#### Docker Compose (Local Testing)

Test the multi-container setup locally:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

#### Cloud Build (CI/CD)

For automated deployments via Cloud Build:

```bash
gcloud builds submit --config cloudbuild.yaml \
  --substitutions=_GEMINI_API_KEY="your-api-key"
```

#### Cost Estimates

- **Cloud Run Free Tier**: 2 million requests/month free
- **Development/Testing**: Typically $0-5/month
- **Production (moderate traffic)**: $10-50/month depending on usage

#### Troubleshooting Cloud Deployment

- **Build fails**: Check `requirements.txt` and Dockerfile syntax
- **503 errors**: Check health endpoint and startup time
- **Environment variables**: Ensure GEMINI_API_KEY is set correctly
- **Memory issues**: Increase memory allocation in deploy command

## 🤖 Contributing

Contributions are welcome! Please open issues or submit PRs with improvements.

