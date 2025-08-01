
import 'package:flutter/material.dart';

class WritingBoard extends StatefulWidget {
  @override
  _WritingBoardState createState() => _WritingBoardState();
}

class _WritingBoardState extends State<WritingBoard> {
  TextEditingController _textController = TextEditingController();
  String savedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Writing Board")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Write something...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
             ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent),
              onPressed: () {
                setState(() => savedText = _textController.text);
              },
              child: Text("Save Text",style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 10),
            if (savedText.isNotEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(savedText, style: TextStyle(fontSize: 16))),
              ),
          ],
        ),
      ),
    );
  }
}
