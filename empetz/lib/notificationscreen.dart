import 'package:flutter/material.dart';

class NOTIFICATION extends StatefulWidget {
  const NOTIFICATION({super.key});

  @override
  State<NOTIFICATION> createState() => _NOTIFICATIONState();
}

class _NOTIFICATIONState extends State<NOTIFICATION> {
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
        centerTitle: true,
        title: Text(
          'Notification',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Chokokutai',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/boy.jpg'),
                ),
                title: Text(
                  'Sooraj',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '9.00Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                 color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/girl.jpg'),
                ),
                title: Text(
                  'Anitha',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '9.15Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
            color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/girl.jpg'),
                ),
                title: Text(
                  'Aswani',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '9.30Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/girl.jpg'),
                ),
                title: Text(
                  'Archana',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '9.45Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/boy.jpg'),
                ),
                title: Text(
                  'Aswajith',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '10.00Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
               color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/boy.jpg'),
                ),
                title: Text(
                  'Narayanan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '10.15Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
               color: Colors.white70,
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/boy.jpg'),
                ),
                title: Text(
                  'Shandha',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'hi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '10.30Am',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
