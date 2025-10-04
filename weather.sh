#!/bin/bash

# TODO: tabs for (tbd, maybe simple current forecast with cloud coverage, temp, sunrise/sunset, wind, humidity; weekly forecast; and a detailed forecast with aqi, uv index dew point, pressure, visibility, moon phase, maybe even a radar idk, etc.; whatever else I think of), ascii art, live clock, and whatever else I can think of


load_symbol() {
    local spin='|/-\'
    local i=0
    
    while ps -p $1 > /dev/null 2>&1; do
        i=$(( (i+1) % 4 ))
        printf "\rConnecting to NWS [${spin:$i:1}] "
        sleep 0.1
    done
    printf "\r\033[K"
}

# Start Python in background, redirect output to temp file
python3 /home/tyler/.local/bin/Terminal-Weather-App/get_weather.py > /tmp/weather_$$.txt &
python_pid=$!

# Show load_symbol
load_symbol $python_pid

# Wait for completion and get result
wait $python_pid
raw_weather_data=$(cat /tmp/weather_$$.txt)
rm /tmp/weather_$$.txt



if [[ $raw_weather_data = "locfail" ]]; then
  echo "Failed to retrieve location"
elif [[ $raw_weather_data = "nwsfail" ]]; then
  echo "Failed to connect to NWS"
else
  IFS=$'\n' read -r -d '' -a weather_data_array <<< "$raw_weather_data"   
fi

#for item in "${weather_data_array[@]}"; do
#  echo "$item"
#done

# unpacking python output:
current_temperature="${weather_data_array[0]}°F"
current_rain_probability="${weather_data_array[1]}%"
current_dewpoint="${weather_data_array[2]}°F"
current_realtive_humidity="${weather_data_array[3]}%"
current_windspeed="${weather_data_array[4]}mph"
current_wind_direction="${weather_data_array[5]}"
current_forecast="${weather_data_array[6]}"

day0=("${weather_data_array[@]:7:3}")
night0=("${weather_data_array[@]:10:3}") 
day1=("${weather_data_array[@]:13:3}")
night1=("${weather_data_array[@]:16:3}")
day2=("${weather_data_array[@]:19:3}")
night2=("${weather_data_array[@]:22:3}")
day3=("${weather_data_array[@]:25:3}")
night3=("${weather_data_array[@]:28:3}")
day4=("${weather_data_array[@]:31:3}")
night4=("${weather_data_array[@]:34:3}")
day5=("${weather_data_array[@]:37:3}")
night5=("${weather_data_array[@]:40:3}")
day6=("${weather_data_array[@]:43:3}")
night6=("${weather_data_array[@]:46:3}")

tput smcup
tput civis

trap 'tput cnorm; tput rmcup' INT TERM EXIT

#tabs() {}

#current_tab() {}
#weekly_tab() {}
# under_construction_tab() {}

while true; do
  read -n 1 -s key

  case $key in
    1) echo "1" ;;
    2) echo "2" ;;
    3) echo "3" ;;
    q) exit 0 ;;
  esac
done
