import streamlit as st
import requests

st.set_page_config(page_title="ravai - AI Powered Travel Planner", page_icon="✈️")

st.title("🌍 Travai - AI Powered Travel Planner")

# ✨ Add start location here
origin = st.text_input("Where are you flying from?", placeholder="e.g., New York")

destination = st.text_input("Destination", placeholder="e.g., Paris")
start_date = st.date_input("Start Date")
end_date = st.date_input("End Date")
budget = st.number_input("Budget (in INR)", min_value=100, step=50)

# 📅 Calendar integration option
add_to_calendar = st.checkbox("📅 Add to Google Calendar", value=False, 
                               help="Automatically create calendar events for your travel plan")

if st.button("Plan My Trip ✨"):
    if not all([origin, destination, start_date, end_date, budget]):
        st.warning("Please fill in all the details.")
    else:
        payload = {
            "origin": origin,
            "destination": destination,
            "start_date": str(start_date),
            "end_date": str(end_date),
            "budget": budget,
            "add_to_calendar": add_to_calendar
        }
        
        with st.spinner("Planning your trip..."):
            response = requests.post("http://localhost:8000/run", json=payload)

        if response.ok:
            data = response.json()
            
            # Display travel plan
            st.subheader("✈️ Flights")
            st.markdown(data["flights"])
            st.subheader("🏨 Stays")
            st.markdown(data["stay"])
            st.subheader("🗺️ Activities")
            st.markdown(data["activities"])
            
            # Display calendar results if requested
            if add_to_calendar and "calendar" in data:
                st.divider()
                calendar_data = data["calendar"]
                
                if calendar_data.get("status") == "success":
                    st.success(f"✅ {calendar_data.get('message', 'Calendar events created!')}")
                    
                    events_created = calendar_data.get("events_created", [])
                    if events_created:
                        st.subheader("📅 Calendar Events Created")
                        for event in events_created:
                            st.markdown(f"- **{event.get('summary')}** - [View in Calendar]({event.get('link')})")
                
                elif calendar_data.get("status") == "credentials_missing":
                    st.error("❌ Google Calendar credentials not found. Please set up OAuth credentials.")
                    st.info("📝 See README.md for instructions on setting up Google Calendar API")
                
                elif calendar_data.get("status") == "no_events":
                    st.warning("⚠️ No events could be extracted from the travel plan")
                
                else:
                    st.error(f"❌ {calendar_data.get('message', 'Failed to create calendar events')}")
        else:
            st.error("Failed to fetch travel plan. Please try again.")
