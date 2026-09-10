import paho.mqtt.client as mqtt
import json
import os

MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC = "WindChaser_sg_segamat/sg_segamat_data"

DATA_FILE = "data.json"
MAX_RECORDS = 500


def parse_message(message):
    data = {}

    for line in message.splitlines():
        if ":" not in line:
            continue

        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()

        if key == "Weather Station":
            data["station_name"] = value

        elif key == "Time":
            data["timestamp"] = value

        elif key == "Battery Voltage":
            data["battery_v"] = float(value.replace(" V", ""))

        elif key == "raw wind direction":
            data["raw_wind_direction"] = float(
                value.replace(" degrees", "")
            )

        elif key == "cali degrees":
            data["cali_degrees"] = float(
                value.replace(" degrees", "")
            )

        elif key == "Wind direction":
            data["wind_direction"] = float(
                value.replace(" degrees", "")
            )

        elif key == "Temperature":
            data["temperature"] = float(value)

        elif key == "Relative humidity":
            data["humidity"] = float(value)

        elif key == "Visible light":
            data["visible_light"] = float(value)

        elif key == "IR":
            data["ir"] = float(value)

        elif key == "UV":
            data["uv"] = float(value)

        elif key == "Pressure":
            data["pressure"] = float(value)

        elif key == "Altitude":
            data["altitude"] = float(value)

    return data


def save_data(data):
    records = []

    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, "r") as f:
                records = json.load(f)

            if not isinstance(records, list):
                records = []

        except Exception:
            records = []

    records.append(data)

    # Keep only the latest records
    records = records[-MAX_RECORDS:]

    with open(DATA_FILE, "w") as f:
        json.dump(records, f, indent=2)

    print(f"Saved to {DATA_FILE} | Total records: {len(records)}")


def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print("========================================")
        print("Connected to MQTT Broker!")
        print("========================================")

        client.subscribe(MQTT_TOPIC, qos=1)

        print(f"Subscribed to: {MQTT_TOPIC}")
        print("Waiting for weather data...\n")

    else:
        print(f"MQTT connection failed: {reason_code}")


def on_message(client, userdata, msg):
    print("\n========================================")
    print("NEW WEATHER DATA")
    print("========================================")

    try:
        message = msg.payload.decode("utf-8")

        print(message)

        data = parse_message(message)

        if data:
            save_data(data)
        else:
            print("WARNING: Could not parse weather data.")

    except Exception as e:
        print(f"Error processing message: {e}")

    print("========================================")


client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

client.on_connect = on_connect
client.on_message = on_message

print("Connecting to MQTT Broker...")

try:
    client.connect(MQTT_BROKER, MQTT_PORT, 60)
    client.loop_forever()

except KeyboardInterrupt:
    print("\nReceiver stopped.")

except Exception as e:
    print(f"Connection error: {e}")

finally:
    client.disconnect()
