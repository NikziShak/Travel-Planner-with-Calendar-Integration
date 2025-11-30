# Deploy ADK Travel Planner to Google Cloud Run (PowerShell version)
# Prerequisites:
# 1. gcloud CLI installed and authenticated
# 2. Docker installed
# 3. GEMINI_API_KEY environment variable set
# 4. Google Cloud project with billing enabled

$ErrorActionPreference = "Stop"

Write-Host "`n=== ADK Travel Planner - Cloud Run Deployment ===`n" -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "Error: gcloud CLI is not installed" -ForegroundColor Red
    Write-Host "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
}

if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Docker is not installed" -ForegroundColor Red
    Write-Host "Install from: https://docs.docker.com/get-docker/"
    exit 1
}

if (!$env:GEMINI_API_KEY) {
    Write-Host "Error: GEMINI_API_KEY environment variable is not set" -ForegroundColor Red
    Write-Host "Set it with: `$env:GEMINI_API_KEY = 'your-api-key'"
    exit 1
}

# Get project ID
$PROJECT_ID = gcloud config get-value project 2>$null
if (!$PROJECT_ID) {
    Write-Host "Error: No GCP project configured" -ForegroundColor Red
    Write-Host "Set it with: gcloud config set project YOUR_PROJECT_ID"
    exit 1
}

Write-Host "✓ All prerequisites met" -ForegroundColor Green
Write-Host "  Project ID: $PROJECT_ID" -ForegroundColor Yellow
Write-Host ""

# Configuration
$REGION = if ($env:REGION) { $env:REGION } else { "us-central1" }
$SERVICE_NAME = "adk-travel-planner"
$IMAGE_NAME = "gcr.io/$PROJECT_ID/$SERVICE_NAME"

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Region: $REGION"
Write-Host "  Service: $SERVICE_NAME"
Write-Host "  Image: $IMAGE_NAME"
Write-Host ""

# Enable required APIs
Write-Host "Enabling required Google Cloud APIs..." -ForegroundColor Yellow
gcloud services enable `
    cloudbuild.googleapis.com `
    run.googleapis.com `
    containerregistry.googleapis.com `
    --project=$PROJECT_ID

Write-Host "✓ APIs enabled`n" -ForegroundColor Green

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t "${IMAGE_NAME}:latest" .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker build successful`n" -ForegroundColor Green
} else {
    Write-Host "✗ Docker build failed" -ForegroundColor Red
    exit 1
}

# Configure Docker for GCR
Write-Host "Configuring Docker authentication..." -ForegroundColor Yellow
gcloud auth configure-docker --quiet

# Push to Google Container Registry
Write-Host "Pushing image to Google Container Registry..." -ForegroundColor Yellow
docker push "${IMAGE_NAME}:latest"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Image pushed successfully`n" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to push image" -ForegroundColor Red
    exit 1
}

# Deploy to Cloud Run
Write-Host "Deploying to Cloud Run..." -ForegroundColor Yellow
gcloud run deploy $SERVICE_NAME `
    --image="${IMAGE_NAME}:latest" `
    --platform=managed `
    --region=$REGION `
    --allow-unauthenticated `
    --port=8501 `
    --memory=2Gi `
    --cpu=2 `
    --timeout=300 `
    --max-instances=10 `
    --set-env-vars="GEMINI_API_KEY=$env:GEMINI_API_KEY" `
    --project=$PROJECT_ID

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Deployment successful!`n" -ForegroundColor Green
} else {
    Write-Host "`n✗ Deployment failed" -ForegroundColor Red
    exit 1
}

# Get the service URL
$SERVICE_URL = gcloud run services describe $SERVICE_NAME `
    --platform=managed `
    --region=$REGION `
    --format='value(status.url)' `
    --project=$PROJECT_ID

Write-Host "=== Deployment Complete ===`n" -ForegroundColor Green
Write-Host "Service URL:" -ForegroundColor Yellow
Write-Host "  $SERVICE_URL`n" -ForegroundColor Green
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "  gcloud run services logs tail $SERVICE_NAME --region=$REGION`n"
Write-Host "To delete the service:" -ForegroundColor Yellow
Write-Host "  gcloud run services delete $SERVICE_NAME --region=$REGION`n"

Write-Host "🚀 Your ADK Travel Planner is now live!" -ForegroundColor Green
Write-Host "Visit: $SERVICE_URL" -ForegroundColor Green
