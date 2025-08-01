import 'dart:convert';
import 'package:empetz/registerscreen.dart';
import 'package:empetz/homescreen.dart'; // Make sure this import is correct
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> Sentdata() async {
    final url = Uri.parse("http://192.168.1.35/Empetz/api/v1/user/login");

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "userName": usernameController.text.trim(),
            "password": passwordController.text.trim(),
          }));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Data post successful');
        print(response.body);

        final data = jsonDecode(response.body);
        String? token = data['token'];
        // Assume your API response includes the username, e.g., data['userName']
        String? fetchedUserName = data[
            'userName']; // Adjust 'userName' if your API uses a different key like 'name'

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token ?? '');
        // Store the username from the API response, or fall back to the entered username
        await prefs.setString(
            'userName', fetchedUserName ?? usernameController.text.trim());

        print('token show $token');
        print(
            'Stored username: ${fetchedUserName ?? usernameController.text.trim()}');

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'Login Successful!',
        )));

        // Navigate to HOMESCREEN and pass the username
        Navigator.pushReplacement(
          // Using pushReplacement is common after login
          context,
          MaterialPageRoute(
            builder: (context) => HOMESCREEN(
                userName: fetchedUserName ?? usernameController.text.trim()),
          ),
        );
      } else {
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        String errorMessage = 'Failed to Login';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          debugPrint('Error parsing error response: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          errorMessage,
        )));
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'An error occurred. Please try again.',
      )));
    }
  }

  String? UsernameError;
  String? PasswordError;

  String? validateUsername(String Username) {
    if (RegExp(r'[!@#<>":_~;[\]\\|=+)(*$^%0-9-]').hasMatch(Username)) {
      return "Username must not contain special characters or numbers.";
    }
    if (Username.isEmpty) {
      return "Username cannot be empty.";
    }
    return null;
  }

  String? validatePassword(String Password) {
    if (Password.length < 9) {
      return 'Password must be at least 9 characters long.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(Password)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(Password)) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        labelText: 'Username', // Changed label for clarity
                        errorText: UsernameError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          UsernameError = validateUsername(value);
                        });
                      }),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        labelText: "Password",
                        errorText: PasswordError,
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
                        PasswordError = validatePassword(value);
                      });
                    },
                  ),
                ),
                SizedBox(height: 40.0),
                Center(
                  child: Container(
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
                        fixedSize: Size(200, 30),
                      ),
                      onPressed: () {
                        setState(() {
                          PasswordError =
                              validatePassword(passwordController.text);
                        });
                        setState(() {
                          UsernameError =
                              validateUsername(usernameController.text);
                        });
                        if (PasswordError == null && UsernameError == null) {
                          Sentdata();
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an Account?",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => registerscreen()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ])),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromARGB(255, 91, 4, 241),
          Colors.pink,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.10,
      size.width * 0.5,
      size.height * 0.20,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.35,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
