"""
Verification Script for ADK Travel Planner
Tests that all packages can be imported and dependencies are available
"""

import sys
import os
from pathlib import Path

# Set UTF-8 encoding for Windows console
if os.name == 'nt':
    sys.stdout.reconfigure(encoding='utf-8')

print("=" * 60)
print("ADK Travel Planner - Verification Script")
print("=" * 60)
print()

# Test 1: Package Imports
print("Test 1: Verifying Python package structure...")
print("-" * 60)

try:
    import agents
    print("✅ agents package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import agents: {e}")
    sys.exit(1)

try:
    import agents.host_agent
    print("✅ agents.host_agent package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import agents.host_agent: {e}")
    sys.exit(1)

try:
    import agents.flight_agent
    print("✅ agents.flight_agent package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import agents.flight_agent: {e}")
    sys.exit(1)

try:
    import agents.stay_agent
    print("✅ agents.stay_agent package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import agents.stay_agent: {e}")
    sys.exit(1)

try:
    import agents.activities_agent
    print("✅ agents.activities_agent package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import agents.activities_agent: {e}")
    sys.exit(1)

try:
    import agents.calendar_agent
    print("✅ agents.calendar_agent package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import agents.calendar_agent: {e}")
    sys.exit(1)

try:
    import shared
    print("✅ shared package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import shared: {e}")
    sys.exit(1)

try:
    import common
    print("✅ common package imported successfully")
except ImportError as e:
    print(f"❌ Failed to import common: {e}")
    sys.exit(1)

print()

# Test 2: Dependency Check
print("Test 2: Checking required dependencies...")
print("-" * 60)

dependencies = {
    "google.adk": "Google ADK",
    "litellm": "LiteLLM",
    "fastapi": "FastAPI",
    "uvicorn": "Uvicorn",
    "streamlit": "Streamlit",
    "httpx": "HTTPX",
    "pydantic": "Pydantic",
}

missing_deps = []

for module, name in dependencies.items():
    try:
        __import__(module)
        print(f"✅ {name} installed")
    except ImportError:
        print(f"❌ {name} NOT installed")
        missing_deps.append(name)

if missing_deps:
    print()
    print("⚠️  Missing dependencies detected!")
    print("   Run: pip install -r requirements.txt")
    sys.exit(1)

print()

# Test 3: Environment Variables
print("Test 3: Checking environment variables...")
print("-" * 60)

import os

gemini_key = os.getenv("GEMINI_API_KEY")
if gemini_key:
    # Mask the key for security
    masked_key = gemini_key[:10] + "..." if len(gemini_key) > 10 else "***"
    print(f"✅ GEMINI_API_KEY is set: {masked_key}")
else:
    print("⚠️  GEMINI_API_KEY is not set")
    print("   Set it using: $env:GEMINI_API_KEY = 'your-api-key'")
    print("   Or the start_all.ps1 script will prompt you for it")

print()

# Test 4: File Structure
print("Test 4: Verifying file structure...")
print("-" * 60)

project_root = Path(__file__).parent
required_files = [
    "requirements.txt",
    "README.md",
    "SETUP_GUIDE.md",
    "KAGGLE_SUBMISSION.md",
    "travel_ui.py",
    "start_all.ps1",
    "agents/__init__.py",
    "agents/host_agent/__init__.py",
    "agents/host_agent/__main__.py",
    "agents/host_agent/agent.py",
    "agents/flight_agent/__init__.py",
    "agents/flight_agent/__main__.py",
    "agents/flight_agent/agent.py",
    "agents/stay_agent/__init__.py",
    "agents/stay_agent/__main__.py",
    "agents/stay_agent/agent.py",
    "agents/activities_agent/__init__.py",
    "agents/activities_agent/__main__.py",
    "agents/activities_agent/agent.py",
    "agents/calendar_agent/__init__.py",
    "agents/calendar_agent/__main__.py",
    "shared/__init__.py",
    "shared/schemas.py",
    "common/__init__.py",
]

missing_files = []

for file_path in required_files:
    full_path = project_root / file_path
    if full_path.exists():
        print(f"✅ {file_path}")
    else:
        print(f"❌ {file_path} NOT FOUND")
        missing_files.append(file_path)

if missing_files:
    print()
    print("⚠️  Some files are missing!")
    sys.exit(1)

print()

# Summary
print("=" * 60)
print("✅ ALL VERIFICATION TESTS PASSED!")
print("=" * 60)
print()
print("Next steps:")
print("1. Ensure GEMINI_API_KEY is set (if not already)")
print("2. Run: .\\start_all.ps1 to start all services")
print("3. Open browser to http://localhost:8501")
print("4. Start planning your trip!")
print()
print("For detailed instructions, see SETUP_GUIDE.md")
print("=" * 60)
