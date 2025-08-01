import 'package:flutter/material.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
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
            "Favorite",
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