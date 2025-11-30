#!/bin/bash

# Deploy ADK Travel Planner to Google Cloud Run
# Prerequisites:
# 1. gcloud CLI installed and authenticated
# 2. Docker installed
# 3. GEMINI_API_KEY environment variable set
# 4. Google Cloud project with billing enabled

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ADK Travel Planner - Cloud Run Deployment ===${NC}\n"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Install from: https://docs.docker.com/get-docker/"
    exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${RED}Error: GEMINI_API_KEY environment variable is not set${NC}"
    echo "Set it with: export GEMINI_API_KEY='your-api-key'"
    exit 1
fi

# Get project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: No GCP project configured${NC}"
    echo "Set it with: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo -e "  Project ID: ${YELLOW}$PROJECT_ID${NC}"
echo ""

# Configuration
REGION=${REGION:-"us-central1"}
SERVICE_NAME="adk-travel-planner"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Region: $REGION"
echo "  Service: $SERVICE_NAME"
echo "  Image: $IMAGE_NAME"
echo ""

# Enable required APIs
echo -e "${YELLOW}Enabling required Google Cloud APIs...${NC}"
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    containerregistry.googleapis.com \
    --project=$PROJECT_ID

echo -e "${GREEN}✓ APIs enabled${NC}\n"

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t $IMAGE_NAME:latest .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker build successful${NC}\n"
else
    echo -e "${RED}✗ Docker build failed${NC}"
    exit 1
fi

# Configure Docker for GCR
echo -e "${YELLOW}Configuring Docker authentication...${NC}"
gcloud auth configure-docker --quiet

# Push to Google Container Registry
echo -e "${YELLOW}Pushing image to Google Container Registry...${NC}"
docker push $IMAGE_NAME:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Image pushed successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to push image${NC}"
    exit 1
fi

# Deploy to Cloud Run
echo -e "${YELLOW}Deploying to Cloud Run...${NC}"
gcloud run deploy $SERVICE_NAME \
    --image=$IMAGE_NAME:latest \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated \
    --port=8501 \
    --memory=2Gi \
    --cpu=2 \
    --timeout=300 \
    --max-instances=10 \
    --set-env-vars="GEMINI_API_KEY=$GEMINI_API_KEY" \
    --project=$PROJECT_ID

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Deployment successful!${NC}\n"
else
    echo -e "\n${RED}✗ Deployment failed${NC}"
    exit 1
fi

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --platform=managed \
    --region=$REGION \
    --format='value(status.url)' \
    --project=$PROJECT_ID)

echo -e "${GREEN}=== Deployment Complete ===${NC}\n"
echo -e "${YELLOW}Service URL:${NC}"
echo -e "  ${GREEN}$SERVICE_URL${NC}\n"
echo -e "${YELLOW}To view logs:${NC}"
echo -e "  gcloud run services logs tail $SERVICE_NAME --region=$REGION\n"
echo -e "${YELLOW}To delete the service:${NC}"
echo -e "  gcloud run services delete $SERVICE_NAME --region=$REGION\n"

echo -e "${GREEN}🚀 Your ADK Travel Planner is now live!${NC}"
echo -e "Visit: ${GREEN}$SERVICE_URL${NC}"
