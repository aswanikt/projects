import 'dart:convert';
import 'package:empetz/about.dart';
import 'package:empetz/addpets.dart';
import 'package:empetz/contact.dart';
import 'package:empetz/Account.dart';
import 'package:empetz/favorite.dart';
import 'package:empetz/notificationscreen.dart';
import 'package:empetz/pets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HOMESCREEN extends StatefulWidget {
  // Add this final variable to receive the username
  final String userName;

  // Update the constructor to require the username
  const HOMESCREEN({super.key, required this.userName});

  @override
  State<HOMESCREEN> createState() => _HOMESCREENState();
}

class _HOMESCREENState extends State<HOMESCREEN> {
  List<dynamic> category = [];
  List<dynamic> petcategory = [];
  String _displayedUserName =
      'User'; // State variable to hold the displayed username
  String? userId;

  @override
  void initState() {
    super.initState();
    // Initialize _displayedUserName with the value passed from the constructor
    _displayedUserName = widget.userName;
    fetchdata();
    petdata();
    _loadUserName(); // Call a new method to handle loading from SharedPreferences
  }

  // Method to load the username from SharedPreferences
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_displayedUserName == 'User' || _displayedUserName.isEmpty) {
        _displayedUserName = prefs.getString('userName') ?? 'User';
      }
      userId = prefs.getString('userId');
    });
  }

  Future<void> fetchUserNameFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final currentUserId = userId ?? prefs.getString('userId');

    if (token.isEmpty || currentUserId == null) {
      debugPrint("Token or user ID is empty. Cannot fetch user name.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.35/Empetz/api/v1/user/$currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        final String fetchedName = userData['name'] ??
            'User'; // Adjust 'name' if your API uses a different key
        await prefs.setString('userName', fetchedName); // Update stored name
        setState(() {
          _displayedUserName = fetchedName;
        });
      } else {
        debugPrint('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }

  Future<void> petdata() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      debugPrint("Token is empty. Cannot fetch pet data.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.35/Empetz/api/v1/user-posted-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          petcategory = json.decode(response.body);
        });
      } else {
        debugPrint('Failed to fetch pet data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load your pets: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching pet data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pets: $e')),
      );
    }
  }

  Future<void> fetchdata() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      debugPrint("Token is empty. Cannot fetch category data.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.35/Empetz/api/v1/category'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          category = json.decode(response.body);
        });
      } else {
        debugPrint('Failed to fetch category data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load categories: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint("Token is null or empty. Cannot proceed with deletion.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Authentication token missing. Please log in again.")),
        );
        return;
      }

      final url = Uri.parse('http://192.168.1.35/Empetz/api/v1/pet/$petId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pet deleted successfully")),
        );
        await petdata();
      } else {
        String errorMessage =
            "Failed to delete pet. Status: ${response.statusCode}";
        try {
          final responseBody = json.decode(response.body);
          errorMessage =
              responseBody['message'] ?? responseBody['error'] ?? errorMessage;
        } catch (e) {
          debugPrint("Could not parse error response: $e");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during deletion: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 91, 4, 241),
                  Colors.pink,
                ],
              ),
            ),
          ),
          title: Text(
            "Home",
            style: TextStyle(
              fontFamily: 'Chokokutai',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NOTIFICATION()),
                );
              },
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Text(
                'BUYER',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'SELLER',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
        ),
        drawer: Drawer(
          elevation: 50,
          shadowColor: const Color.fromARGB(255, 209, 61, 61),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 91, 4, 241),
                      Colors.pink,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Align text to start
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/th.jpg'), // Placeholder image
                    ),
                    SizedBox(height: 10),
                    Text(
                      _displayedUserName, // Display the username here
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text(
                    'Account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Account()));
                  },
                ),
              ),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.favorite_sharp),
                  title: Text(
                    'Favorite',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Favorite()));
                  },
                ),
              ),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.question_mark_rounded),
                  title: Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => About()));
                  },
                ),
              ),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text(
                    'Contact Us',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Contact()));
                  },
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // BUYER TAB
            category.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: category.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Pets(
                                categoryId: category[index]['id'],
                                categoryName: category[index]['name'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundImage: NetworkImage(
                                  category[index]['imagePath'] ?? '',
                                ),
                                onBackgroundImageError:
                                    (exception, stackTrace) {
                                  debugPrint(
                                      "Error loading category image: $exception");
                                },
                              ),
                              SizedBox(height: 8),
                              Text(
                                category[index]['name'] ?? 'Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // SELLER TAB
            Stack(
              children: [
                petcategory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 60, color: Colors.grey[400]),
                            SizedBox(height: 10),
                            Text(
                              "No pets posted yet. Click '+' to add one!",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80),
                        itemCount: petcategory.length,
                        itemBuilder: (context, index) {
                          final pet = petcategory[index];
                          final name = pet['name'] ?? 'Unnamed Pet';
                          final price = pet['price']?.toString() ?? 'N/A';
                          final id = pet['id'].toString();
                          final imageBase64 = pet['image'];

                          ImageProvider? petImage;
                          if (imageBase64 != null && imageBase64.isNotEmpty) {
                            try {
                              petImage = MemoryImage(base64Decode(imageBase64));
                            } catch (e) {
                              debugPrint("Error decoding base64 image: $e");
                              petImage =
                                  AssetImage('assets/placeholder_pet.png');
                            }
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: petImage ??
                                        AssetImage(
                                            'assets/placeholder_pet.png'),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Price: ₹$price',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deletePet(id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Addpets(pet: {})),
                      );
                      if (result == true) {
                        petdata();
                      }
                    },
                    backgroundColor: const Color.fromARGB(255, 91, 4, 241),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
