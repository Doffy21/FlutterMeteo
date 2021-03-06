import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import "package:http/http.dart" as http;
import 'package:weather_app/key.dart';

enum Status { PENDING, ACTIVE, ERROR }

class API {
  const API._();
  static const instance = API._();

  final String host = "api.openweathermap.org";

  ///The final URL would look like this:
  ///[https://<host>/data/2.5/weather?lat=<lat>&lon=<lon>&units=metric&appid=<APPI_KEY>]
  Uri uri({String lat, String lon}) => Uri(
        scheme: "https",
        host: host,
        pathSegments: {"data", "2.5", "weather"},
        queryParameters: {"lat": lat, "lon": lon, "units": "metric", "appid": API_KEY},
      );

  Future<Weather> getCurrentWeather() async {
    try {
      ///get the current location of the user!
      ///Using the geolocator package: https://pub.dev/packages/geolocator
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      ///Now we will construct our Uri using the static method uri(),
      ///passing lon & lat parameteres as required by the API.
      ///Check the endpoint docs here: https://openweathermap.org/current
      final Uri requestUri = uri(
        lon: position.longitude.toString(),
        lat: position.latitude.toString(),
      );

      ///After we hav a uri, we can now send our request using
      ///http package: https://pub.dev/packages/http, and the result
      ///will be stored in a variable `response`.
      final http.Response response = await http.get(requestUri);

      ///The response, if recieaved correctly. will be in the form of `json`
      ///so in order to read the data inside of it, we first need to decode it,
      ///by using the `json.decode()` method from the built-in [dart:convert] package,
      final Map<String, dynamic> decodedJson = json.decode(response.body);

      ///Finally we will transform the response into a [Weather] object, and return
      ///it to be used in the UI.
      return Weather.fromMap(decodedJson);
    } on SocketException catch (e) {
      print(e);
      throw "You don't have connection, try again later.";
    } on PlatformException catch (e) {
      throw "${e.message}, please allow the app to access your current location from the settings.";
    } catch (e) {
      throw "Unknown error, try again.";
    }
  }
}

class Weather {
  final int temp;
  final String city;
  final String country;
  final String main;
  final String desc;
  final String icon;

  String getIcon() => Uri(
        scheme: "https",
        host: "openweathermap.org",
        pathSegments: {"img", "wn", "$icon@2x.png"},
      ).toString();

  Weather.fromMap(Map<String, dynamic> json)
      : temp = json['main']['temp'].toInt(),
        city = json['name'],
        country = json['sys']['country'],
        main = json['weather'][0]['main'],
        desc = json['weather'][0]['description'],
        icon = json['weather'][0]['icon'];
}
