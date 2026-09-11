#!/bin/bash

cd ~/WeatherStationSegamat

while true
do
    git add data.json

    if ! git diff --cached --quiet; then
        git commit -m "Update weather data"
        git push
    fi

    sleep 60
done
