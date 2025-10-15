#!/bin/bash

# TODO: tabs for (tbd, maybe simple current forecast with cloud coverage, temp, sunrise/sunset, wind, humidity; weekly forecast; and a detailed forecast with aqi, uv index dew point, pressure, visibility, moon phase, maybe even a radar idk, etc.; whatever else I think of), ascii art, live clock, and whatever else I can think of

load_symbol() {
  local spin='|/-\'
  local i=0

  while ps -p "$1" >/dev/null 2>&1; do
    i=$(((i + 1) % 4))
    printf "\rConnecting to NWS [${spin:$i:1}] "
    sleep 0.1
  done
  printf "\r\033[K"
}

# Start Python in background, redirect output to temp file
python3 /home/tyler/.local/bin/Terminal-Weather-App/get_weather.py >/tmp/weather_$$.txt &
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
  IFS=$'\n' read -r -d '' -a weather_data_array <<<"$raw_weather_data"
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

location="${weather_data_array[50]}"
ip="${weather_data_array[51]}"

UnderlineStart=$(tput smul)
RES=$(tput sgr0)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# functions defined here so I don't have to pass variables to them everytime, they can just use the global variables above them
current_tab_one() { # 136x36 is your current default terminal
  clear
  tput cud 1
  echo -e "                     > ${UnderlineStart}Current Forecast${RES}                      Weekly Forecast                      Other Information"
  tput cup 33 112
  echo "[q] to quit."
  tput cup 32 20
  echo "Location : $location"
  tput cup 33 18
  echo "IP Address : $ip"

  # printing table for data
  tput dim
  tput cup 4 65
  echo "┌────────────────────────────┬────────────────────────────┐"
  tput cup 5 65
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 5)) 65
  done
  tput cup 5 94
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 5)) 94
  done
  tput cup 5 123
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 5)) 123
  done
  tput cup 13 65
  echo "├────────────────────────────┼────────────────────────────┤"
  tput cup 14 65
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 14)) 65
  done
  tput cup 14 94
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 14)) 94
  done
  tput cup 14 123
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 14)) 123
  done
  tput cup 22 65
  echo "├────────────────────────────┼────────────────────────────┤"
  tput cup 23 65
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 23)) 65
  done
  tput cup 23 94
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 23)) 94
  done
  tput cup 23 123
  for i in {1..8}; do
    echo "│"
    tput cup $((i + 23)) 123
  done
  tput cup 31 65
  echo "└────────────────────────────┴────────────────────────────┘"
  tput sgr0
  # Filling table with data
  tput cup 7 74
  echo "Temperature:"
  tput cup 9 78
  if [[ ${weather_data_array[0]} -gt 100 ]]; then
    tput setaf 196
  elif [[ ${weather_data_array[0]} -gt 80 ]]; then
    tput setaf 208
  elif [[ ${weather_data_array[0]} -gt 60 ]]; then
    tput setaf 226
  elif [[ ${weather_data_array[0]} -gt 40 ]]; then
    tput setaf 118
  elif [[ ${weather_data_array[0]} -gt 20 ]]; then
    tput setaf 51
  elif [[ ${weather_data_array[0]} -gt 0 ]]; then
    tput setaf 21
  else
    tput setaf 93
  fi
  echo "${current_temperature}"
  tput sgr0
  tput cup 7 98
  echo "% Chance Precipitation:"
  tput cup 9 108
  if [[ ${weather_data_array[1]} -lt 10 ]]; then
    tput sgr0
  elif [[ ${weather_data_array[1]} -lt 40 ]]; then
    tput setaf 87
  elif [[ ${weather_data_array[1]} -lt 70 ]]; then
    tput setaf 39
  else
    tput setaf 27
  fi
  echo "${current_rain_probability}"
  tput sgr0
  tput cup 16 76
  echo "Windspeed:"
  tput cup 18 78
  if [[ ${weather_data_array[4]} -lt 6 ]]; then
    tput sgr0
  elif [[ ${weather_data_array[4]} -lt 17 ]]; then
    tput setaf 226
  elif [[ ${weather_data_array[4]} -lt 37 ]]; then
    tput setaf 208
  else
    tput setaf 196
  fi
  echo "${current_windspeed}"
  tput sgr0
  tput cup 16 102
  echo "Wind Direction:"
  tput cup 18 108
  echo "${current_wind_direction}"
  # big case ik
  case $current_wind_direction in
  N)
    tput cup 19 108
    echo "◯"
    tput cup 17 108
    echo "●"
    ;;
  NNE)
    tput cup 17 110
    echo "●"
    tput cup 19 108
    echo "◯"
    ;;
  NE)
    tput cup 17 110
    echo "●"
    tput cup 19 107
    echo "◯"
    ;;
  ENE)
    tput cup 17 112
    echo "●"
    tput cup 19 106
    echo "◯"
    ;;
  E)
    tput cup 18 110
    echo "●"
    tput cup 18 106
    echo "◯"
    ;;
  ESE)
    tput cup 17 106
    echo "◯"
    tput cup 19 112
    echo "●"
    ;;
  SE)
    tput cup 17 107
    echo "◯"
    tput cup 19 110
    echo "●"
    ;;
  SSE)
    tput cup 17 108
    echo "◯"
    tput cup 19 110
    echo "●"
    ;;
  S)
    tput cup 19 108
    echo "●"
    tput cup 17 108
    echo "◯"
    ;;
  SSW)
    tput cup 17 110
    echo "◯"
    tput cup 19 108
    echo "●"
    ;;
  SW)
    tput cup 17 110
    echo "◯"
    tput cup 19 107
    echo "●"
    ;;
  WSW)
    tput cup 17 112
    echo "◯"
    tput cup 19 106
    echo "●"
    ;;
  W)
    tput cup 18 110
    echo "◯"
    tput cup 18 106
    echo "●"
    ;;
  WNW)
    tput cup 17 106
    echo "●"
    tput cup 19 112
    echo "◯"
    ;;
  NW)
    tput cup 17 107
    echo "●"
    tput cup 19 110
    echo "◯"
    ;;
  NNW)
    tput cup 17 108
    echo "●"
    tput cup 19 110
    echo "◯"
    ;;
  esac
  tput cup 25 71
  echo "Relative Humidity:"
  tput cup 27 79
  if [[ ${weather_data_array[3]} -lt 26 ]]; then
    tput sgr0
  elif [[ ${weather_data_array[3]} -lt 51 ]]; then
    tput setaf 87
  elif [[ ${weather_data_array[3]} -lt 76 ]]; then
    tput setaf 39
  else
    tput setaf 27
  fi
  echo "${current_realtive_humidity}"
  tput setaf sgr0
  tput cup 25 105
  echo "Dewpoint:"
  tput cup 27 107
  no_decimal=${weather_data_array[2]//./}
  if [[ $no_decimal -lt 5000 ]]; then
    tput sgr0
  elif [[ $no_decimal -lt 6000 ]]; then
    tput setaf 226
  elif [[ $no_decimal -lt 7000 ]]; then
    tput setaf 208
  else
    tput setaf 196
  fi
  echo "${current_dewpoint}"

  # ASCII art
  case $current_forecast in
  Sunny)
    tput cup 5 0
    cat "$SCRIPT_DIR/Terminal-Weather-App/ascii_art/sunny.txt"
    ;;
  Clear)
    tput cup 7 0
    cat "$SCRIPT_DIR/Terminal-Weather-App/ascii_art/clear.txt"
    ;;
  Cloudy)
    tput cup 5 0
    cat "$SCRIPT_DIR/Terminal-Weather-App/ascii_art/cloudy.txt"
    ;;
  Rain)
    tput cup 3 0
    cat "$SCRIPT_DIR/Terminal-Weather-App/ascii_art/rain.txt"
    ;;
  Snow)
    tput cup 5 0
    cat "$SCRIPT_DIR/Terminal-Weather-App/ascii_art/snow.txt"
    ;;
  Thunderstorms)
    tput cup 3 0
    cat "$SCRIPT_DIR/Terminal-Weather-App/ascii_art/thunderstorms.txt"
    ;;
  esac
}

weekly_tab_two() {
  clear
  tput cud 1
  echo "                       Current Forecast                    > ${UnderlineStart}Weekly Forecast${RES}                      Other Information"
  tput cup 33 112
  echo "[q] to quit."
}

under_construction_tab_three() {
  clear
  tput cud 1
  echo "                       Current Forecast                      Weekly Forecast                    > ${UnderlineStart}Other Information${RES}"
  tput cup 33 112
  echo "[q] to quit."
}

tput smcup
tput civis
clear

trap 'tput cnorm; tput rmcup; exit 0' INT TERM EXIT

current_tab_one

while true; do
  read -r -n 1 -s key

  case $key in
  1) current_tab_one ;;
  2) weekly_tab_two ;;
  3) under_construction_tab_three ;;
  q) exit 0 ;;
  esac
done
