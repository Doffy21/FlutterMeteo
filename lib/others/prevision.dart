import 'dart:convert';
import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/models/forcast.dart';
import 'package:weather_app/models/location.dart';

import 'package:weather_app/others/data.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import 'models.dart';


class Prevision extends StatefulWidget {
  final String cityName;
  Prevision({ this.cityName});

  @override
  State<StatefulWidget> createState() => _PrevisionState();
}

class _PrevisionState extends State<Prevision> {
  final _cityTextController = TextEditingController();
  final _dataService = DataService();

  WeatherResponse _response;

  void _search() async {
    final response = await _dataService.getWeather(widget.cityName);
    setState(() => _response = response);
  }

  Future getForecast() async {
    Forecast forecast;
    String apiKey = "98e8dfcf4ea2319b693eb4c58b2a6018";
    double lat = _response.coordsInfo.lat;
    double lon = _response.coordsInfo.lon;
    var url =
        "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      forecast = Forecast.fromJson(jsonDecode(response.body));
    }

    return forecast;
  }


  @override
  void initState(){
    super.initState();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.grey[100],
            body:
            ListView(
                children: <Widget>[
                  forcastViewsHourly(),
                  forcastViewsDaily(),
                ]
            )
        )
    );
  }

  Image getWeatherIcon(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 70,
      height: 70,
    );
  }

  Image getWeatherIconSmall(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 40,
      height: 40,
    );
  }

  String getTimeFromTimestamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formatter = new DateFormat('h:mm a');
    return formatter.format(date);
  }

  String getDateFromTimestamp(int timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formatter = new DateFormat('E');
    return formatter.format(date);
  }

  Widget hourlyBoxes(Forecast _forecast) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        height: 150.0,
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _forecast.hourly.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  padding: const EdgeInsets.only(
                      left: 10, top: 15, bottom: 15, right: 10),
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: Offset(0, 1), // changes position of shadow
                        )
                      ]),
                  child: Column(children: [
                    Text(
                      "${_forecast.hourly[index].temp}°",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.black),
                    ),
                    getWeatherIcon(_forecast.hourly[index].icon),
                    Text(
                      "${getTimeFromTimestamp(_forecast.hourly[index].dt)}",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.grey),
                    ),
                  ]));
            }));
  }

  Widget forcastViewsHourly() {
    Forecast _forcast;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _forcast = snapshot.data;
          if (_forcast == null) {
            return Text("Error getting weather");
          } else {
            return hourlyBoxes(_forcast);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
      future: getForecast(),
    );
  }

  Widget dailyBoxes(Forecast _forcast) {
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 8),
            itemCount: _forcast.daily.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  padding: const EdgeInsets.only(
                      left: 10, top: 5, bottom: 5, right: 10),
                  margin: const EdgeInsets.all(5),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                          "${getDateFromTimestamp(_forcast.daily[index].dt)}",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        )),
                    Expanded(
                        child: getWeatherIconSmall(_forcast.daily[index].icon)),
                    Expanded(
                        child: Text(
                          "${_forcast.daily[index].high.toInt()}/${_forcast.daily[index].low.toInt()}",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        )),
                  ]));
            }));
  }

  Widget forcastViewsDaily() {
    Forecast _forcast;

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _forcast = snapshot.data;
          if (_forcast == null) {
            return Text("Error getting weather");
          } else {
            return dailyBoxes(_forcast);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
      future: getForecast(),
    );
  }


}