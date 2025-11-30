# ADK-Powered Travel Planner - Stop All Services
# This script stops all running agent services and Streamlit UI

Write-Host "🛑 Stopping ADK-Powered Travel Planner services..." -ForegroundColor Red
Write-Host ""

# Function to kill processes on a specific port
function Stop-ServiceOnPort {
    param (
        [int]$Port,
        [string]$ServiceName
    )
    
    $connections = netstat -ano | Select-String ":$Port\s" | Select-String "LISTENING"
    
    if ($connections) {
        foreach ($connection in $connections) {
            $parts = $connection -split '\s+' | Where-Object { $_ -ne '' }
            $pid = $parts[-1]
            
            if ($pid -and $pid -match '^\d+$') {
                try {
                    Write-Host "🔴 Stopping $ServiceName (Port $Port, PID $pid)..." -ForegroundColor Yellow
                    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
                    Write-Host "✅ Stopped $ServiceName" -ForegroundColor Green
                }
                catch {
                    Write-Host "❌ Could not stop PID $pid" -ForegroundColor Red
                }
            }
        }
    }
    else {
        Write-Host "ℹ️  $ServiceName (Port $Port) - Not running" -ForegroundColor Gray
    }
}

# Stop all services
Stop-ServiceOnPort -Port 8000 -ServiceName "Host Agent"
Stop-ServiceOnPort -Port 8001 -ServiceName "Flight Agent"
Stop-ServiceOnPort -Port 8002 -ServiceName "Stay Agent"
Stop-ServiceOnPort -Port 8003 -ServiceName "Activities Agent"
Stop-ServiceOnPort -Port 8004 -ServiceName "Calendar Agent"
Stop-ServiceOnPort -Port 8501 -ServiceName "Streamlit UI"

Write-Host ""
Write-Host "✅ All services stopped!" -ForegroundColor Green
Write-Host "💡 You can close any remaining PowerShell windows manually" -ForegroundColor Yellow
Write-Host ""

# Wait for user to see the message
Start-Sleep -Seconds 3
