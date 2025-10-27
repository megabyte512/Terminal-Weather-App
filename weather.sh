#!/bin/bash

# TODO ideas: sunrise/sunset, a detailed forecast with aqi, uv index dew point, pressure, visibility, moon phase, maybe even a radar, live clock or "report generated on/at"

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

# weekly weather data formatted like:
# temp.
# chance precip.
# forecast
# date
# this goes on for the next 14 cycles (day/night have unique values)
# 14*4 = 56 vars, starting at index 7 (8th element in the array)
# we will store this block in a separate array, so we won't have to
# worry about shifting by 7 everytime.
weekly_weather=("${weather_data_array[@]:7:56}")

location="${weather_data_array[64]}"
ip="${weather_data_array[65]}"

# some macros
UnderlineStart=$(tput smul)
RES=$(tput sgr0)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# this function draws a vertical bar with input params as labeled below
vertical_box_line() {
  local start_row=$1
  local start_col=$2
  local height=$3
  tput cup "$start_row" "$start_col"
  for (( i=0; i<=height; i++ )); do
    echo "│"
    tput cup "$((i + start_row))" "$start_col"
  done
}

# this function decides which emoji to print based on the input forecast
weather_emoji() {
  local weather=$1
  case $weather in
    "Sunny") echo "☀️" ;;
    "Clear") echo "🌙" ;;
    "Rain") echo "💧" ;;
    "Snow") echo "❄️" ;;
    "Cloudy") echo "☁️" ;;
    "Thunderstorms") echo "⚡" ;;
    "Fog") echo "🌫️" ;;
    *) echo "❓[$weather]" ;;  # Shows what didn't match
   esac
}

# tab functions defined here so I don't have to pass variables to them everytime, they can just use the global variables above them
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
  vertical_box_line 5 65 8
  vertical_box_line 5 94 8
  vertical_box_line 5 123 8
  tput cup 13 65
  echo "├────────────────────────────┼────────────────────────────┤"
  vertical_box_line 14 65 8
  vertical_box_line 14 94 8
  vertical_box_line 14 123 8
  tput cup 22 65
  echo "├────────────────────────────┼────────────────────────────┤"
  vertical_box_line 23 65 8
  vertical_box_line 23 94 8
  vertical_box_line 23 123 8
  tput cup 31 65
  echo "└────────────────────────────┴────────────────────────────┘"
  tput sgr0
  # Filling table with data and changing color based on value
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
  # printing a little graphic for wind direction.
  # solid circle is where the wind is coming from.
  # empty circle is where the wind is travelling to.
  # You'll notice that "N" for example means wind is coming from the
  # north, not travelling to the north. idk why this is the standard.
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
  tput cup 32 20
  echo "Location : $location"
  tput cup 33 18
  echo "IP Address : $ip"
  # print dates
  tput cup 4 7
  echo "> ${UnderlineStart}${weekly_weather[3]}${RES}"
  for i in {0..5}; do
    tput cup 4 "$((18*i + 25))"
    echo "${weekly_weather[8*i + 15]}"
  done
  # You may have noticed that we have 3 for loops here. It should, in theory, be possible with
  # one, but for some reason the data wouldn't print correctly when table and data
  # were put in the same loop. Not the biggest deal. Just looks stupid.
  tput dim
  for i in {0..6}; do
    # setting up top row table thing
    vertical_box_line 7 "$((18*i + 4))" 3
    echo "╰─────"
  done
  for i in {0..6}; do
    # setting up bottom row table thing
    vertical_box_line 13 "$((18*i + 8))" 3
    echo "╰─────"
  done
  tput sgr0
  for i in {0..6}; do
    # filling top row with data
    # temp
    tput cup 8 "$((18*i + 6))"
    echo "${weekly_weather[8*i]}°F"
    # chance precip.
    tput cup 9 "$((18*i + 6))"
    echo "${weekly_weather[8*i + 1]}%"
    # forecast icon/emoji
    tput cup 7 "$((i*18 + 6))"
    weather_emoji "${weekly_weather[8*i + 2]}" 
    # filling bottom row with data
    # temp
    tput cup 14 "$((18*i + 10))"
    echo "${weekly_weather[8*i + 4]}°F"
    # chance precip.
    tput cup 15 "$((18*i + 10))"
    echo "${weekly_weather[8*i + 5]}%"
    # forecast icon/emoji
    tput cup 13 "$((18*i + 10))"
    weather_emoji "${weekly_weather[8*i + 6]}"
  done
}

# Haven't gotten around to this yet. Ideas for what will go here on line 3^
other_information_tab_three() {
  clear
  tput cud 1
  echo "                       Current Forecast                      Weekly Forecast                    > ${UnderlineStart}Other Information${RES}"
  tput cup 33 112
  echo "[q] to quit."
  tput cup 18 60
  echo "UNDER CONSTRUCTION"
}

# setting up terminal to clear and hide cursor
tput smcup
tput civis
clear

# upon exit, run these
trap 'tput cnorm; tput rmcup; exit 0' INT TERM EXIT

# default to tab 1
current_tab_one

# listen for "1, 2, 3, and q" keys and decide what to do thereafter
while true; do
  read -r -n 1 -s key

  case $key in
  1) current_tab_one ;;
  2) weekly_tab_two ;;
  3) other_information_tab_three ;;
  q) exit 0 ;;
  esac
done
