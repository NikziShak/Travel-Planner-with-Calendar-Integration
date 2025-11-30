# ADK-Powered Travel Planner - Start All Services
# This script starts all agent services and the Streamlit UI

Write-Host "Starting ADK-Powered Travel Planner..." -ForegroundColor Cyan
Write-Host ""

# Check if GEMINI_API_KEY is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "WARNING: GEMINI_API_KEY not found in environment!" -ForegroundColor Yellow
    Write-Host "Please set your Gemini API key:" -ForegroundColor Yellow
    $apiKey = Read-Host "Enter your GEMINI_API_KEY"
    $env:GEMINI_API_KEY = $apiKey
}

Write-Host "Using GEMINI_API_KEY: $($env:GEMINI_API_KEY.Substring(0, 10))..." -ForegroundColor Green
Write-Host ""

# Get the current directory
$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Get-Location
}

Write-Host "Project directory: $projectDir" -ForegroundColor Gray
Write-Host ""

# Check if virtual environment exists
$venvPath = Join-Path $projectDir "venv\Scripts\activate.ps1"
$activateCmd = ""
if (Test-Path $venvPath) {
    $activateCmd = ". '$venvPath';"
    Write-Host "Virtual environment found - will activate" -ForegroundColor Green
}
else {
    Write-Host "No virtual environment found - using system Python" -ForegroundColor Yellow
}
Write-Host ""

# Function to start a service
function Start-AgentService {
    param (
        [string]$Name,
        [string]$Command,
        [int]$Port
    )
    
    Write-Host "Starting $Name on port $Port..." -ForegroundColor Cyan
    
    $scriptBlock = @"
cd '$projectDir'
$activateCmd
`$env:GEMINI_API_KEY='$env:GEMINI_API_KEY'
Write-Host '$Name running on port $Port' -ForegroundColor Green
$Command
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock
    Start-Sleep -Seconds 2
}

# Start all agent services
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  Starting Agent Services" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Start-AgentService -Name "Host Agent" -Command "uvicorn agents.host_agent.__main__:app --port 8000" -Port 8000
Start-AgentService -Name "Flight Agent" -Command "uvicorn agents.flight_agent.__main__:app --port 8001" -Port 8001
Start-AgentService -Name "Stay Agent" -Command "uvicorn agents.stay_agent.__main__:app --port 8002" -Port 8002
Start-AgentService -Name "Activities Agent" -Command "uvicorn agents.activities_agent.__main__:app --port 8003" -Port 8003
Start-AgentService -Name "Calendar Agent" -Command "uvicorn agents.calendar_agent.__main__:app --port 8004" -Port 8004

Write-Host ""
Write-Host "Waiting for all services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "  Starting Streamlit UI" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Start Streamlit UI in the current terminal
Write-Host "Launching Streamlit UI..." -ForegroundColor Cyan
Write-Host "The browser will open automatically at http://localhost:8501" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop all services:" -ForegroundColor Yellow
Write-Host "   1. Close the Streamlit browser tab" -ForegroundColor Yellow
Write-Host "   2. Press Ctrl+C here" -ForegroundColor Yellow
Write-Host "   3. Close all PowerShell windows that opened" -ForegroundColor Yellow
Write-Host ""

if ($activateCmd) {
    Invoke-Expression $activateCmd
}

streamlit run travel_ui.py
