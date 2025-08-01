
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String weather = "Sunny";
  double temp = 25.0;

  void _changeWeather() {
    final random = (temp + (5 - (10 * (DateTime.now().second % 2))).clamp(10.0, 35.0));
    setState(() {
      temp = random;
      weather = random > 28 ? "Sunny" : random > 20 ? "Cloudy" : "Rainy";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BoxedIcon(
              weather == "Sunny" ? WeatherIcons.day_sunny :
              weather == "Cloudy" ? WeatherIcons.cloudy :
              WeatherIcons.rain,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              "$weather",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "${temp.toStringAsFixed(1)}°C",
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _changeWeather,
              child: Text("Update Weather"),
            ),
          ],
        ),
      ),
    );
  }
}