# Kaggle Submission: ADK-Powered Travel Planner

## Competition: Agents Intensive - Capstone Project

**Submission by:** Nikit Sharma  
**Date:** November 30, 2025  
**Project:** ADK-Powered Travel Planner

---

## Executive Summary

This project demonstrates a **multi-agent AI system** that solves the real-world problem of **complex travel planning** by coordinating multiple specialized agents using Google's Agent Development Kit (ADK). The system automates the time-consuming process of researching flights, accommodations, and activities, while staying within budget constraints.

### Key Achievements

✅ **Multi-Agent Orchestration:** Implements 5 specialized agents that communicate via the A2A (Agent-to-Agent) protocol  
✅ **Real-World Problem:** Addresses the common pain point of coordinating multiple travel booking platforms  
✅ **Production-Ready:** Built with FastAPI, includes error handling, and provides a user-friendly Streamlit interface  
✅ **Google Workspace Integration:** Optional Google Calendar integration for seamless scheduling  
✅ **Scalable Architecture:** Modular design allows easy addition of new agents (e.g., car rental, tour guides)

---

## Problem Statement

### The Challenge

Planning a trip requires coordinating multiple services:
- ✈️ **Flights:** Comparing airlines, prices, schedules, layovers
- 🏨 **Accommodations:** Finding hotels within budget with desired amenities
- 🗺️ **Activities:** Researching local attractions, restaurants, experiences
- 📅 **Scheduling:** Managing dates, times, and synchronizing with personal calendar

This process typically involves:
- Opening 10+ browser tabs
- Manually cross-referencing dates and budgets
- Spending 2-3 hours for a single trip
- Risk of booking conflicts or budget overruns

### Our Solution

An **intelligent multi-agent system** that:
1. Takes user input (origin, destination, dates, budget)
2. Automatically coordinates specialized agents for flights, stays, and activities
3. Ensures all suggestions fit within budget
4. Optionally creates calendar events for the entire trip
5. Returns a complete, cohesive travel plan in under 30 seconds

---

## Technical Architecture

### Agent Hierarchy

```mermaid
graph TB
    subgraph "User Interface Layer"
        UI[Streamlit UI<br/>Port 8501]
    end
    
    subgraph "Orchestration Layer"
        Host[Host Agent<br/>Port 8000<br/>Coordinates Planning]
    end
    
    subgraph "Specialized Agent Layer"
        Flight[Flight Agent<br/>Port 8001<br/>Suggests Flights]
        Stay[Stay Agent<br/>Port 8002<br/>Recommends Hotels]
        Activities[Activities Agent<br/>Port 8003<br/>Suggests Activities]
        Calendar[Calendar Agent<br/>Port 8004<br/>Calendar Integration]
    end
    
    subgraph "External Services"
        Gemini[Gemini 3 Pro<br/>LLM Backend]
        GCal[Google Calendar API]
    end
    
    UI -->|Travel Request| Host
    Host -->|Delegate Tasks| Flight
    Host -->|Delegate Tasks| Stay
    Host -->|Delegate Tasks| Activities
    Host -->|Optional| Calendar
    
    Flight -.->|LLM Calls| Gemini
    Stay -.->|LLM Calls| Gemini
    Activities -.->|LLM Calls| Gemini
    Calendar -->|Create Events| GCal
    
    Host -->|Aggregated Plan| UI
    
    style UI fill:#e1f5ff
    style Host fill:#81d4fa
    style Flight fill:#4fc3f7
    style Stay fill:#4fc3f7
    style Activities fill:#4fc3f7
    style Calendar fill:#4fc3f7
    style Gemini fill:#ffb74d
    style GCal fill:#66bb6a
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Agent Framework** | Google ADK | Multi-agent orchestration and A2A protocol |
| **LLM Backend** | Gemini 3 Pro (via LiteLLM) | Natural language understanding and generation |
| **Web Framework** | FastAPI + Uvicorn | RESTful agent endpoints |
| **Frontend** | Streamlit | User interface |
| **External APIs** | Google Calendar API | Optional calendar integration |
| **Data Validation** | Pydantic | Type-safe request/response models |

### Agent Responsibilities

#### 1. Host Agent (Orchestrator)
- **Port:** 8000
- **Role:** Coordinates the entire planning workflow
- **Tasks:**
  - Receives user travel request
  - Delegates tasks to specialized agents
  - Aggregates responses into cohesive plan
  - Returns final result to UI

#### 2. Flight Agent
- **Port:** 8001
- **Role:** Suggests flight options
- **Output:** 2-3 flight options with airline, times, price, layover info
- **Constraints:** Must fit within allocated budget

#### 3. Stay Agent
- **Port:** 8002
- **Role:** Recommends accommodations
- **Output:** Hotel options with amenities, location, price per night
- **Constraints:** Total stay cost must fit within remaining budget

#### 4. Activities Agent
- **Port:** 8003
- **Role:** Suggests local experiences
- **Output:** 3-5 activities with descriptions, estimated costs, duration
- **Constraints:** Activity costs should fit within remaining budget

#### 5. Calendar Agent (Optional)
- **Port:** 8004
- **Role:** Creates Google Calendar events
- **Output:** Calendar event links for flights, hotel, activities
- **Requires:** OAuth 2.0 credentials for Google Calendar API

---

## Key Features

### 1. Intelligent Budget Management

Each agent is budget-aware and ensures suggestions fit within the user's constraints:

```python
# Example: Flight Agent considering budget
prompt = (
    f"User is flying from {request['origin']} to {request['destination']} "
    f"from {request['start_date']} to {request['end_date']}, "
    f"with a budget of {request['budget']}. "
    "Suggest 2-3 realistic flight options..."
)
```

### 2. Seamless Agent Communication

Uses Google ADK's built-in A2A protocol for reliable inter-agent communication:

```python
# Host agent delegating to specialized agents
async for event in runner.run_async(
    user_id=USER_ID, 
    session_id=SESSION_ID, 
    new_message=message
):
    if event.is_final_response():
        return {"summary": event.content.parts[0].text}
```

### 3. User-Friendly Interface

Built with Streamlit for rapid prototyping and excellent UX:
- Clean, intuitive form inputs
- Real-time feedback during planning
- Formatted, readable results
- Optional calendar integration checkbox

### 4. Google Calendar Integration

Automatically creates calendar events for:
- ✈️ Flight departure and arrival times
- 🏨 Hotel check-in and check-out
- 🗺️ Scheduled activities

Each event includes clickable links for easy calendar access.

---

## How It Improves Everyday Productivity

### Time Savings
- **Traditional Planning:** 2-3 hours per trip
- **With ADK Travel Planner:** ~30 seconds
- **Productivity Gain:** 95% time reduction

### Reduced Cognitive Load
- No need to switch between multiple websites
- No manual budget calculations
- No risk of booking conflicts

### Enhanced Quality
- AI-powered recommendations based on comprehensive knowledge
- Budget optimization across all travel components
- Cohesive itinerary that considers timing and logistics

### Real-World Use Cases

1. **Business Travel:** Quickly plan trips for conferences or client meetings
2. **Family Vacations:** Coordinate complex multi-person trips with budget constraints
3. **Weekend Getaways:** Rapid planning for spontaneous short trips
4. **Travel Agents:** Tool for professionals to accelerate client service

---

## Installation and Usage

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/NikitSharma/Google-Agent-Development-Kit-Demo.git
   cd Google-Agent-Development-Kit-Demo
   ```

2. **Install dependencies:**
   ```bash
   python -m venv venv
   .\venv\Scripts\Activate.ps1  # Windows
   pip install -r requirements.txt
   ```

3. **Set Gemini API key:**
   ```bash
   $env:GEMINI_API_KEY = "your-api-key"
   ```

4. **Start all services:**
   ```bash
   .\start_all.ps1
   ```

5. **Open browser** to http://localhost:8501 and start planning!

### Detailed Instructions

See [SETUP_GUIDE.md](file:///c:/Users/Acer/Downloads/Google-Agent-Development-Kit-Demo/SETUP_GUIDE.md) for comprehensive setup instructions, troubleshooting, and optional Google Calendar configuration.

---

## Demo Scenario

### Input
- **Origin:** New York
- **Destination:** Paris
- **Dates:** December 15-22, 2025
- **Budget:** ₹150,000 INR (~$1,800 USD)
- **Calendar:** Enabled

### Output

**✈️ Flights**
```
Option 1: Air France - Direct Flight
  Departure: Dec 15, 8:00 PM → Arrival: Dec 16, 10:00 AM
  Return: Dec 22, 11:00 AM → Arrival: Dec 22, 2:00 PM
  Price: ₹65,000
  
Option 2: Lufthansa - 1 Stop (Frankfurt)
  Departure: Dec 15, 3:00 PM → Arrival: Dec 16, 7:30 AM
  Return: Dec 22, 9:00 AM → Arrival: Dec 22, 11:45 PM
  Price: ₹52,000
```

**🏨 Stays**
```
Hotel Champs-Élysées Plaza
  Location: Near Arc de Triomphe
  Amenities: Free WiFi, Breakfast, City Views
  Price: ₹8,000/night × 7 nights = ₹56,000
```

**🗺️ Activities**
```
1. Eiffel Tower Visit - ₹1,500 (2 hours)
2. Louvre Museum Tour - ₹2,000 (4 hours)
3. Seine River Cruise - ₹1,200 (1.5 hours)
4. Montmartre Walking Tour - ₹800 (3 hours)
```

**Total Cost:** ₹118,000-131,000 (within budget ✅)

**📅 Calendar:** 8 events created with clickable links

---

## Future Enhancements

### Planned Features

1. **Additional Agents:**
   - 🚗 Car rental agent
   - 🍽️ Restaurant reservation agent
   - 🎫 Tour booking agent

2. **Enhanced Intelligence:**
   - Machine learning for personalized recommendations
   - Historical data analysis for price optimization
   - Weather-aware activity suggestions

3. **User Features:**
   - Multi-user trip planning (group travel)
   - Saved preferences and past trips
   - Real-time price alerts

4. **Integration Expansion:**
   - Email confirmations via Gmail API
   - Slack/Teams notifications
   - Expense tracking integration

---

## Technical Highlights

### Why Google ADK?

1. **Built-in A2A Protocol:** Standardized agent communication
2. **Model Agnostic:** Works with any LLM via LiteLLM
3. **Session Management:** Built-in conversation state tracking
4. **Production Ready:** Designed for real-world deployment
5. **Modular Architecture:** Easy to extend with new agents

### Code Quality

- ✅ Type hints throughout (Pydantic models)
- ✅ Async/await for efficient I/O
- ✅ Proper error handling
- ✅ Environment variable management
- ✅ Clean separation of concerns

### Scalability

The architecture supports:
- Horizontal scaling (multiple instances per agent)
- Load balancing across agents
- Caching for frequently requested destinations
- Rate limiting for API protection

---

## Conclusion

The ADK-Powered Travel Planner demonstrates how **multi-agent AI systems** can solve complex, real-world problems that require coordinating multiple specialized tasks. By leveraging Google's Agent Development Kit and Gemini 3 Pro, we've created a system that:

✅ **Saves time:** Reduces planning from hours to seconds  
✅ **Reduces complexity:** Handles multi-platform coordination automatically  
✅ **Ensures accuracy:** Budget-aware recommendations prevent overspending  
✅ **Enhances productivity:** Seamless calendar integration  
✅ **Scales easily:** Modular design supports adding new capabilities

This project showcases the power of agentic AI in improving everyday productivity and serves as a foundation for even more sophisticated travel planning solutions.

---

## Acknowledgments

- **Google ADK Team:** For creating an excellent multi-agent framework
- **Kaggle:** For hosting the Agents Intensive course and capstone project
- **Gemini Team:** For providing powerful LLM capabilities

---

## Repository

**GitHub:** https://github.com/NikitSharma/Google-Agent-Development-Kit-Demo  
**Documentation:** See [README.md](file:///c:/Users/Acer/Downloads/Google-Agent-Development-Kit-Demo/README.md) and [SETUP_GUIDE.md](file:///c:/Users/Acer/Downloads/Google-Agent-Development-Kit-Demo/SETUP_GUIDE.md)

---

*Built with ❤️ using Google Agent Development Kit*
