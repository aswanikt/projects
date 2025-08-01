
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boold/donor.dart';

class My_blood extends StatefulWidget {
  const My_blood(
      {super.key,
      required this.name,
      required this.phone,
      required this.bloodGroup});

  final String name;
  final String phone;
  final String bloodGroup;

  @override
  State<My_blood> createState() => _My_bloodState();
}

class _My_bloodState extends State<My_blood> {
  List<Map<String, String>> bloodData = [];

  @override
  void initState() {
    super.initState();
    _saveData();
    _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> previousData = prefs.getStringList('bloodData') ?? [];
    String newData = '${widget.name},${widget.phone},${widget.bloodGroup}';
    previousData.insert(0, newData);
    await prefs.setStringList('bloodData', previousData);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedData = prefs.getStringList('bloodData') ?? [];
    setState(() {
      bloodData = storedData.map((e) {
        List<String> details = e.split(',');
        return {
          'name': details[0],
          'phone': details[1],
          'bloodGroup': details[2]
        };
      }).toList();
    });
  }

  Future<void> _deleteData(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedData = prefs.getStringList('bloodData') ?? [];
    storedData.removeAt(index);
    await prefs.setStringList('bloodData', storedData);
    setState(() {
      bloodData.removeAt(index);
    });
  }

  Future<void> _editData(int index) async {
    Map<String, String> currentItem = bloodData[index];
    TextEditingController nameController =
        TextEditingController(text: currentItem['name']);
    TextEditingController phoneController =
        TextEditingController(text: currentItem['phone']);
    String? selectedBloodGroup = currentItem['bloodGroup'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Donor Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            DropdownButton<String>(
              value: selectedBloodGroup,
              isExpanded: true,
              hint: const Text("Select Blood Group"),
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => selectedBloodGroup = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save updated data
              final prefs = await SharedPreferences.getInstance();
              List<String> storedData = prefs.getStringList('bloodData') ?? [];
              storedData[index] =
                  '${nameController.text},${phoneController.text},${selectedBloodGroup}';
              await prefs.setStringList('bloodData', storedData);

              // Update UI
              setState(() {
                bloodData[index] = {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'bloodGroup': selectedBloodGroup!,
                };
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[500],
        automaticallyImplyLeading: false, // Removes the back arrow
        title: const Text(
          "BLOOD",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
      body: bloodData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bloodData.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text('${bloodData[index]['bloodGroup'] ?? ''}'),
                    ),
                    title: Text('${bloodData[index]['name'] ?? ''}'),
                    subtitle: Text('${bloodData[index]['phone'] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteData(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editData(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const My_donor()),
          );
        },
        child: Icon(Icons.add, color: Colors.red[500]),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
