import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
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
            "Account",
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

