import requests

# NWS User-Agent required header
headers = {
    'User-Agent': 'personal_terminal_weather_app (shlolfwall@gmail.com)'
}

loc_url = "https://ipinfo.io/json"
nws_url = "https://api.weather.gov/points/"

# cleaning the "Short Forecast" from NWS
unwanted_forecast_jargon = [
    'Scattered', 'And', 'then', 'Slight', 'Chance', 'Partly',
    'Mostly', ' ', 'mph', 'Likely', 'Showers', 'Isolated'
]


def strip(s):
    for removable in unwanted_forecast_jargon:
        if s.find(removable) != -1:
            s = s.replace(removable, '')
    if s.find('Rain') > -1:
        s = s.replace('Sunny', '')
        s = s.replace('Cloudy', '')
    if s.find('Snow') > -1:
        s = s.replace('Rain', '')
        s = s.replace('Sunny', '')
    return s

# calling ipinfo.io for coordinates. A lot of these
# variables are unused ik. Honestly just practicing
# parsing json files


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
    print('locfail')

response = requests.get(f"{nws_url}{location}", headers=headers)
if response.status_code == 200:
    # extracting useful URLs
    properties = response.json()['properties']
    forecast_url = properties['forecast']
    hourly_url = properties['forecastHourly']
    grid_data_url = properties['forecastGridData']
else:
    print('nwsfail')
# failure check for requests not necessary
# now that we already know we can connect to NWS

# Current weather output
hourly_response = requests.get(hourly_url, headers=headers)
current_weather = hourly_response.json()['properties']['periods'][1]
print(current_weather['temperature'])
print(current_weather['probabilityOfPrecipitation']['value'])
print(round(current_weather['dewpoint']['value'], 2))
print(current_weather['relativeHumidity']['value'])
print(strip(current_weather['windSpeed']))
print(current_weather['windDirection'])
print(strip(current_weather['shortForecast']))

# Weekly weather output
weekly_response = requests.get(forecast_url, headers=headers)
weekly_weather = weekly_response.json()['properties']['periods']
for i in range(14):
    print(weekly_weather[i]['temperature'])
    print(weekly_weather[i]['probabilityOfPrecipitation']['value'])
    print(strip(weekly_weather[i]['shortForecast']))
    date = weekly_weather[i]['startTime']
    date_cleaned = date.split('T')  # We just care about the date
    date = date_cleaned[0]          # resetting date variable
    date_cleaned = date.split('-')  # Splitting again based off API format
    del date_cleaned[0]             # deleting year (we don't care about that)
    separator = '/'
    date = separator.join(date_cleaned)  # putting it all together
    print(date)


# For more detailed outputs if I decide to add them (like a radar map idk)
# response = requests.get(grid_data_url, headers=headers)
# print(response.json())

# for viewing json structure
print(f"forecast url:{forecast_url} hourly url:{hourly_url} grid data url:{grid_data_url}")
print(location)
print(ip)
