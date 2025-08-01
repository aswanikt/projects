import 'package:flutter/material.dart';

class TypingBoard extends StatefulWidget {
  const TypingBoard({super.key});

  @override
  State<TypingBoard> createState() => TypingBoardState();
}

class TypingBoardState extends State<TypingBoard> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _savedNames = [];

  void _saveName() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _savedNames.add(name);
      _controller.clear();
    });
  }

  void _deleteName(int index) {
    setState(() {
      _savedNames.removeAt(index);
    });
  }

  void _editName(int index) {
    final TextEditingController editController =
        TextEditingController(text: _savedNames[index]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final editedName = editController.text.trim();
              if (editedName.isNotEmpty) {
                setState(() {
                  _savedNames[index] = editedName;
                });
              }
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "In-Memory List",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Enter your name"),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _saveName,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save Name"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _savedNames.isEmpty
                  ? const Center(
                      child: Text("No names saved yet."),
                    )
                  : ListView.builder(
                      itemCount: _savedNames.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          shadowColor: Colors.deepPurple,
                          child: ListTile(
                            title: Text(
                              _savedNames[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editName(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteName(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
