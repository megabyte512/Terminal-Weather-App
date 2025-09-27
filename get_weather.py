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
response = requests.get(forecast_url, headers=headers)
print(response.json())

response = requests.get(hourly_url, headers=headers)
print(response.json())

response = requests.get(grid_data_url, headers=headers)
print(response.json())
