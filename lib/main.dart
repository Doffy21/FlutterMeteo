import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/others/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Weather currentWeather;
  Status status;
  String error = "";

  Future<void> getWeather() async {
    String _error = "";

    try {
      final _currentWeather = await API.instance.getCurrentWeather();

      setState(() {
        currentWeather = _currentWeather;
        status = Status.ACTIVE;
      });
    } catch (e) {
      _error = e;
      setState(() {
        error = _error;
        status = Status.ERROR;
      });
      return;
    }
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

  @override
  void initState() {
    status = Status.PENDING;
    getWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          )
        ),
        child: RefreshIndicator(
          onRefresh: getWeather,
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (status == Status.PENDING)
                      Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    if (status == Status.ACTIVE)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.indigo,
                              ),
                              Text("${currentWeather.city}, ${currentWeather.country}",style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                              ),
                            ],
                          ),
                          SizedBox(height: 80,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text('Maintenant', style: TextStyle(fontWeight: FontWeight.bold,),

                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "${currentWeather.temp.toString()}°c ",
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(currentWeather.getIcon(), height: 80),
                              Text(
                                "${currentWeather.main}: ${currentWeather.desc}",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          SizedBox(height: 70,),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                SizedBox(width: 20,),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Accueil(cityName: "Abidjan",)));
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/abi.png"),
                                              fit: BoxFit.cover,
                                            )
                                        ),
                                      ),

                                    ),
                                    Text('Abidjan', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 18),)
                                  ],
                                ),
                                SizedBox(width: 20,),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Accueil(cityName: "Paris",)));
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/pa.png"),
                                              fit: BoxFit.cover,
                                            )
                                        ),
                                      ),

                                    ),
                                    Text('Paris',style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 18),)
                                  ],
                                ),
                                SizedBox(width: 20,),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Accueil(cityName: "Bruxelles",)));
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/brux.png"),
                                              fit: BoxFit.cover,
                                            )
                                        ),
                                      ),


                                    ),
                                    Text('Bruxelle', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 18),)
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
              Column(
                children: [

                  if (status == Status.ERROR)
                    HighlightedMsg(
                      msg: "$error",
                      color: Colors.red[100],
                    ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}

class HighlightedMsg extends StatelessWidget {
  const HighlightedMsg({
    Key key,
    @required this.msg,
    this.color,
  }) : super(key: key);
  final String msg;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: color ?? Theme.of(context).highlightColor),
        padding: EdgeInsets.all(20),
        child: Text(
          msg,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class OutlineBtn extends StatefulWidget {
  final String btnText;

  OutlineBtn({ this.btnText}) ;

  @override
  _OutlineBtnState createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<OutlineBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade800),
        borderRadius: BorderRadius.circular(50),
      ),
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          widget.btnText,
          style: TextStyle(color: Colors.blue.shade800, fontSize: 18),
        ),
      ),
    );
  }
}

