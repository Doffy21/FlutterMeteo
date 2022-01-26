/*
{
  "weather": [
    {
      "description": "clear sky",
      "icon": "01d"
    }
  ],
  "main": {
    "temp": 282.55,
  },

  "name": "Mountain View",
}
 */

class WeatherInfo {
  final String description;
  final String icon;

  WeatherInfo({this.description, this.icon});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final description = json['description'];
    final icon = json['icon'];
    return WeatherInfo(description: description, icon: icon);
  }
}

class TemperatureInfo {
  final double temperature;
  final int pressure;
  final int humidity;
  final double tempMin;
  final double tempMax;


  TemperatureInfo({this.temperature, this.humidity,this.pressure, this.tempMax, this.tempMin});

  factory TemperatureInfo.fromJson(Map<String, dynamic> json) {
    final temperature = json['temp'];
    final humidity = json['humidity'];
    final pressure = json['pressure'];
    final tempMax = json['temp_max'];
    final tempMin = json['temp_min'];

    return TemperatureInfo(temperature: temperature, humidity: humidity, pressure: pressure, tempMax: tempMax, tempMin: tempMin);
  }
}

class CoordsInfo {

  final double lon;
  final double lat;


  CoordsInfo({this.lon, this.lat});

  factory CoordsInfo.fromJson(Map<String, dynamic> json) {
    final lon = json['lon'];
    final lat = json['lat'];


    return CoordsInfo(lon: lon, lat: lat);
  }
}

class WeatherResponse {
  final String cityName;
  final TemperatureInfo tempInfo;
  final WeatherInfo weatherInfo;
  final CoordsInfo coordsInfo;

  String get iconUrl {
    return 'https://openweathermap.org/img/wn/${weatherInfo.icon}@2x.png';
  }

  WeatherResponse({this.cityName, this.tempInfo, this.weatherInfo, this.coordsInfo});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final cityName = json['name'];

    //final tempInfoJson = json['main'];
    final tempInfoJson = json['main'];
    final tempInfo = TemperatureInfo.fromJson(tempInfoJson);

    final coordInfoJson = json['coord'];
    final coordsInfo = CoordsInfo.fromJson(coordInfoJson);

    final weatherInfoJson = json['weather'][0];
    final weatherInfo = WeatherInfo.fromJson(weatherInfoJson);

    return WeatherResponse(
        cityName: cityName, tempInfo: tempInfo, weatherInfo: weatherInfo, coordsInfo: coordsInfo);
  }
}