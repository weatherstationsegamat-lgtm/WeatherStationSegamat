# SG Segamat Weather App — Phase Pipeline

## Goal
Deliver a polished Android-first community weather app from Phase 1 through Phase 9.

## Shared requirements
- Bahasa Melayu first-class language with English switch.
- Clear, accessible community-facing UI.
- Live station data comes from the GitHub `data.json` feed.
- No MQTT credentials in the mobile app.
- Show Malaysia time (GMT+8) consistently.
- Never invent sensor values, station data, or derived metrics when required inputs are missing.

## Phase 1 — Live Dashboard
- Current temperature
- Relative humidity
- Wind direction
- UV
- Visible light
- Pressure
- Altitude
- Battery voltage when available
- Last updated
- Station online/offline
- LIVE status
- Auto refresh
- Pull to refresh
- SG_Segamat identity
- BM/English language switch

## Phase 2 — Data & Graphs
- Temperature, humidity, pressure, UV, visible-light, battery and wind-direction history
- Time ranges: 1h, 6h, 24h, 7d, 30d
- Minimum, average and maximum
- Highest/lowest markers
- Date selection
- Empty/stale-data handling

## Phase 3 — Wind
- Current direction
- Compass presentation
- Wind rose
- Dominant direction
- Direction-change visualization
- Wind speed only when the source data provides it

## Phase 4 — Alerts
- High/low temperature
- High UV
- Humidity thresholds
- Low battery
- Station offline
- Stale data
- User-configurable thresholds and toggles

## Phase 5 — Data Tools
- CSV export
- Share CSV
- History download/share
- Daily report
- Weekly report
- Daily/weekly statistics
- Extremes

## Phase 6 — App Experience
- Dark/light mode
- BM/English
- Phone/tablet responsive layout
- Loading/error states
- Last-known data cache/offline fallback
- Data unavailable state
- Polished weather-app experience instead of a JSON viewer

## Phase 7 — SG Segamat AI
- Ask about current weather
- Compare today vs yesterday when history supports it
- Hottest/coolest time
- UV suitability
- Trend explanations
- Answers must be grounded in real station data

## Phase 8 — Multi-station
- Station selector architecture
- Multiple stations when data sources exist
- Map view when station coordinates exist
- Do not invent stations or coordinates

## Phase 9 — Advanced Analytics
- Trend prediction with clear uncertainty
- Anomaly detection
- Heat index
- Dew point
- Apparent temperature
- UV risk summary
- Weather-condition summary
- Calendar history
- Shareable weather card
- Deep links
- Notification architecture
- Sensor diagnostics
- Station health score

## Quality gate for every phase
1. Flutter formatting/checks
2. `flutter analyze`
3. `flutter test`
4. Release APK build
5. APK output verification
6. Human-readable build summary

A phase is not considered complete merely because code exists; it must pass the quality gate.