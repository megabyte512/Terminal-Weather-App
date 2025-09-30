import requests

# NWS User-Agent required header
headers = {
    'User-Agent': 'personal_terminal_weather_app (shlolfwall@gmail.com)'
}

loc_url = "https://ipinfo.io/json"
nws_url = "https://api.weather.gov/points/"
response = requests.get(loc_url)

if response.status_code == 200: 
    data = response.json() 
    ip = data['ip']
    city = data['city']
    region = data['region']
    country = data['country']
    location = data['loc']
    zip = data['postal']
else:
    print("locfail")


response = requests.get(f"{nws_url}{location}", headers=headers)

if response.status_code == 200:
    # extracting useful URLs
    properties = response.json()['properties']
    forecast_url = properties['forecast']
    hourly_url = properties['forecastHourly']
    grid_data_url = properties['forecastGridData']
    #print(f"forecast url:{forecast_url} hourly url:{hourly_url} grid data url:{grid_data_url}") # for viewing json structure
else:
    print('nwsfail')

# failure check for requests not necessary now that we already know we can connect to NWS

# TODO: print data as cleanly as possible for weather.sh

# Current weather output
hourly_response = requests.get(hourly_url, headers=headers)
current_weather = hourly_response.json()['properties']['periods'][0]
print(current_weather['temperature'])
print(current_weather['probabilityOfPrecipitation']['value'])
print(current_weather['dewpoint']['value'])
print(current_weather['relativeHumidity']['value'])
print(current_weather['windSpeed'])
print(current_weather['windDirection'])
print(current_weather['shortForecast'])
print()

# Weekly weather output
weekly_response = requests.get(forecast_url, headers=headers)
weekly_weather = weekly_response.json()['properties']['periods']
for i in range(14):
    print(weekly_weather[i]['temperature'])
    print(weekly_weather[i]['probabilityOfPrecipitation']['value'])

# For more detailed outputs if I decide to add them
#response = requests.get(grid_data_url, headers=headers)
#print(response.json())
