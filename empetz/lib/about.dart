import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 91, 4, 241),
                Colors.pink,
              ],
            )),
          ),
            title: Text(
            "About",
            style: TextStyle(
                fontFamily: 'Chokokutai',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30),
          ),
          centerTitle: true,
          ),
    );
  }
}