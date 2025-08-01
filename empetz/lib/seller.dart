import 'package:empetz/addpets.dart';
import 'package:flutter/material.dart';

class sellerscreen extends StatefulWidget {
  const sellerscreen({super.key});

  @override
  State<sellerscreen> createState() => _sellerscreenState();
}

class _sellerscreenState extends State<sellerscreen> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(

          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => Addpets(
                        pet: {},
                      )),
            );
          }),
    );
  }
}






