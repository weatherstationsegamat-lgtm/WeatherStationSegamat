# SG Segamat Weather Station — Mobile App

Android-first companion app for the SG Segamat weather station.

## Data source
Reads the public `data.json` from this repository. The app does not connect directly to MQTT, so no MQTT credentials are stored in the phone app.

## Current backend flow
Weather Station → MQTT → Enzonic → `data.json` → GitHub → Mobile App

## Planned screens
- Live dashboard: temperature, humidity, wind direction, UV, visible light, pressure, altitude
- Historical trend charts
- Station status and last update
- Bahasa Melayu / English

## Development
The mobile implementation can be generated with Flutter and built as an Android APK/AAB.