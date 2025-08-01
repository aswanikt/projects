import 'dart:convert';
import 'package:empetz/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class registerscreen extends StatefulWidget {
  const registerscreen({super.key});

  @override
  State<registerscreen> createState() => _registerscreenState();
}

class _registerscreenState extends State<registerscreen> {
  bool isChecked = false;
  bool _obscureText = true;
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> Sentdata() async {
    final url =
        Uri.parse("http://192.168.1.35/Empetz/api/v1/user/registration");

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstName": firstnameController.text.trim(),
          "userName": usernameController.text.trim(),
          "phone": phoneNumberController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Data post successfull');
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Data sent Successfully',
      )));
    } else {
      print("response.statuscode");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Failed to sent data',
      )));
    }
  }

  String? firstnameError;
  String? usernameError;
  String? phoneNumberError;
  String? emailError;
  String? passwordError;

  String? validatedfirstname(String name) {
    if (RegExp(r'[!@#<>?":_~;[\]\\|=+(*&^%0-9-)]').hasMatch(name)) {
      return 'Username must not contain special characters or numbers';
    }
    if (name.isEmpty) {
      return 'name cannot be empty';
    }
    return null;
  }

  String? validateusername(String username) {
    if (RegExp(r'[!@#<>?":_~;[\]\\|=+(*&^%0-9-)]').hasMatch(username)) {
      return 'Username must not contain special characters or numbers';
    }
    if (username.isEmpty) {
      return 'username cannot be empty';
    }
    return null;
  }

  String? validatePassword(String Password) {
    if (Password.length < 6) {
      return 'password must be at least 6 characters long';
    }

    if (!RegExp(r'[A-Z]').hasMatch(Password)) {
      return 'password must be at least one upercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(Password)) {
      return 'password must be at least one number';
    }
    return null;
  }

  String? validatePhoneNumber(String phoneNumber) {
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      return 'phone number must be exactly 10 digits';
    }
    return null;
  }

  String? validateEmail(String email) {
    if (email.length < 6) {
      return 'email must be at least 6 characters long';
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      return 'email must be at least one upercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(email)) {
      return 'email must be at least one number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: firstnameController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      labelText: 'First Name',
                      errorText: firstnameError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        firstnameError = validatedfirstname(value);
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      labelText: 'User Name',
                      errorText: usernameError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        usernameError = validateusername(value);
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      labelText: 'Phone Number',
                      errorText: phoneNumberError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        phoneNumberError = validatePhoneNumber(value);
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      labelText: 'Email',
                      errorText: emailError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        emailError = validateEmail(value);
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: passwordController,
                    maxLength: 10,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        labelText: 'Password',
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )),
                    onChanged: (value) {
                      setState(() {
                        passwordError = validatePassword(value);
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 91, 4, 241),
                          Colors.pink,
                        ],
                      )),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      fixedSize: Size(150, 30),
                    ),
                    onPressed: () {
                      setState(() {
                        firstnameError =
                            validatedfirstname(firstnameController.text);
                        passwordError =
                            validatePassword(passwordController.text);
                        usernameError =
                            validateusername(usernameController.text);
                        emailError = validateEmail(emailController.text);
                        phoneNumberError =
                            validatePhoneNumber(phoneNumberController.text);
                      });
                      if (passwordError == null &&
                          usernameError == null &&
                          emailError == null &&
                          firstnameError == null &&
                          passwordError == null) {
                        Sentdata();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Register Successfully')));
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      }
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an Account?",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
