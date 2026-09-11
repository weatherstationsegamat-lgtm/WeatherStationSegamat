// SG_Segamat station data is the primary live source.
// Open-Meteo (loaded by script.js) remains the fallback when station data is >15 minutes old.

const STATION_DATA_URL = `./data.json?t=${Date.now()}`;
const STATION_TIMEOUT_MS = 15 * 60 * 1000;
let stationFallbackBusy = false;

function parseStationTimestamp(value) {
  if (!value) return NaN;
  // Station timestamps are Kuala Lumpur local time (UTC+8).
  return new Date(String(value).replace(" ", "T") + "+08:00").getTime();
}

function stationToWeather(record) {
  const temperature = Number(record.temperature);
  const humidity = Number(record.humidity);
  const windDirection = Number(record.wind_direction);
  if (!Number.isFinite(temperature) || !Number.isFinite(humidity)) return null;

  return {
    temperature_2m: temperature,
    relative_humidity_2m: humidity,
    precipitation: NaN,
    wind_speed_10m: NaN,
    apparent_temperature: temperature,
    wind_direction_10m: Number.isFinite(windDirection) ? windDirection : 0,
    time: String(record.timestamp).replace(" ", "T")
  };
}

function renderStationWeather(record) {
  const data = stationToWeather(record);
  if (!data) return false;

  // Reuse the existing renderer so the current website design stays unchanged.
  renderWeather(data);

  const set = (id, value) => {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
  };

  // SG_Segamat does not provide rainfall or wind-speed measurements.
  set("rainfall", "--");
  set("wind", "--");

  // Keep the station timestamp as the authoritative last-updated time.
  set("currentDate", fmtDate(data.time));
  set("updatedTime", fmtTime(data.time));

  return true;
}

function renderStationTrend(records) {
  if (typeof trendData === "undefined" || typeof renderTrendRange !== "function") return;

  const cutoff = Date.now() - 24 * 60 * 60 * 1000;
  const points = records
    .map(r => ({
      time: parseStationTimestamp(r.timestamp),
      value: Number(r.temperature)
    }))
    .filter(p => Number.isFinite(p.time) && p.time >= cutoff && Number.isFinite(p.value))
    .sort((a, b) => a.time - b.time)
    .map(p => ({
      value: p.value,
      label: fmtTime(p.time)
    }));

  // The live station feed is normally every minute. Keep the chart readable
  // by showing at most 24 hourly samples, including the latest reading.
  let sampled = points;
  if (points.length > 24) {
    const step = (points.length - 1) / 23;
    sampled = Array.from({ length: 24 }, (_, i) => points[Math.round(i * step)]);
  }

  if (sampled.length >= 2) {
    trendData.today = sampled;
    if (activeTrendRange === "24") renderTrendRange("24");
  }
}

async function loadStationFallback() {
  if (stationFallbackBusy) return;
  stationFallbackBusy = true;

  try {
    const response = await fetch(`./data.json?t=${Date.now()}`, { cache: "no-store" });
    if (!response.ok) throw new Error("Station data unavailable");

    const records = await response.json();
    if (!Array.isArray(records) || records.length === 0) throw new Error("No station records");

    const latest = records[records.length - 1];
    const latestTime = parseStationTimestamp(latest.timestamp);
    if (!Number.isFinite(latestTime)) throw new Error("Invalid station timestamp");

    const age = Date.now() - latestTime;

    if (age <= STATION_TIMEOUT_MS) {
      // Station is alive: immediately use the newest SG_Segamat reading.
      renderStationWeather(latest);
      renderStationTrend(records);

      const status = document.querySelector(".status-bar .online");
      if (status) {
        status.classList.remove("offline");
        status.innerHTML = `● <span data-t="online">${T[currentLang].online}</span>`;
      }
    }
    // If age > 15 minutes, do nothing here.
    // The normal script.js Open-Meteo reading remains on screen as fallback.
  } catch (error) {
    console.warn("SG_Segamat station data unavailable; keeping Open-Meteo fallback.", error);
  } finally {
    stationFallbackBusy = false;
  }
}

// Run once after the existing Open-Meteo loader, then keep checking every minute.
loadStationFallback();
setInterval(loadStationFallback, 60000);
