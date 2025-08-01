import 'package:boold/blood.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class My_donor extends StatefulWidget {
  const My_donor({super.key});

  @override
  State<My_donor> createState() => _My_donorState();
}

class _My_donorState extends State<My_donor> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  TextEditingController updatecontroller = TextEditingController();
  String? phoneNumberError;
  String? nameError;
  String? categoryError;
  String? selectedCategory;

  String? validatedName(String name) {
    if (name.isEmpty) return 'Name cannot be empty';
    if (RegExp(r'[!@#<>?":_~;[\]\\|=+(*&^%0-9-]').hasMatch(name)) {
      return 'Name must not contain special characters or numbers';
    }
    return null;
  }

  String? validatePhoneNumber(String phoneNumber) {
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a blood group';
    }
    return null;
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('phone', phoneNumberController.text);
    await prefs.setString('bloodGroup', selectedCategory ?? '');
  }
   
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[500],
        title: const Text(
          "Donor",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Enter Name",
                  errorText: nameError,
                ),
                onChanged: (value) =>
                    setState(() => nameError = validatedName(value)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  errorText: phoneNumberError,
                ),
                onChanged: (value) {
                  setState(() {
                    phoneNumberError = validatePhoneNumber(value);
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  hint: Text("Select Blood Group"),
                  underline: SizedBox(), // Removes default underline
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      categoryError = validateCategory(value);
                    });
                  },
                ),
              ),
            ),
            if (categoryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  categoryError!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  nameError = validatedName(nameController.text);
                  phoneNumberError =
                      validatePhoneNumber(phoneNumberController.text);
                  categoryError = validateCategory(selectedCategory);
                });
                if (nameError == null &&
                    phoneNumberError == null &&
                    categoryError == null) {
                  _saveData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => My_blood(
                        name: nameController.text,
                        phone: phoneNumberController.text,
                        bloodGroup: selectedCategory!,
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
