import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PetProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> pet;

  const PetProfilePage({super.key, required this.pet, required this.userId});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  Map<String, dynamic> ownerDetails = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOwnerDetails();
  }

  Future<void> fetchOwnerDetails() async {
    if (widget.userId.isEmpty) {
      setState(() {
        _errorMessage = 'No owner information available';
        _isLoading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.35/Empetz/user/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        ownerDetails = json.decode(response.body);
      } else {
        _errorMessage = 'Failed to load owner details';
      }
    } catch (_) {
      _errorMessage = 'Error loading owner details';
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            child: pet['imagePath'] != null
                                ? Image.network(
                                    pet['imagePath'],
                                    height: 300,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 250,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.pets, size: 100),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet['name'] ?? 'Unnamed',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  pet['breedName'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (pet['age'] != null)
                                  _infoRowWithIcon(
                                      Icons.cake, pet['age'].toString()),
                                if (pet['discription'] != null)
                                  _infoRowWithIcon(
                                      Icons.info, pet['discription']),
                                const SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.deepPurple),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            pet['locationName'] ??
                                                'Location not specified',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: pet['locationName'] == null
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (pet['address'] != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.home,
                                              color: Colors.deepPurple),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              pet['address'],
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statBox('Gender', pet['gender'] ?? 'N/A'),
                                _statBox(
                                    'Height', '${pet['height'] ?? 'N/A'} cm'),
                                _statBox(
                                    'Weight', '${pet['weight'] ?? 'N/A'} kg'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (pet['price'] != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  const Icon(Icons.currency_rupee,
                                      color: Colors.deepPurple),
                                  Text("${pet['price']}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      )),
                                ],
                              ),
                            ),
                          const SizedBox(height: 30),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Owner Details",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Card(
                                  shadowColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _infoRowWithIcon(
                                                    Icons.person,
                                                    ownerDetails['firstName'] ??
                                                        ownerDetails['name'] ??
                                                        'Not specified',
                                                  ),
                                                  _infoRowWithIcon(
                                                    Icons.email,
                                                    ownerDetails['email'] ??
                                                        'Not specified',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (ownerDetails['phone'] != null)
                                              IconButton(
                                                icon: const Icon(Icons.call,
                                                    color: Colors.green),
                                                onPressed: () => _launchPhone(
                                                    ownerDetails['phone']),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
          Positioned(
            top: 1,
            left: 5,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  Widget _infoRowWithIcon(IconData icon, String? value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? 'Not specified',
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _launchPhone(String phone) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (!await launchUrl(phoneLaunchUri)) {
      throw 'Could not launch $phoneLaunchUri';
    }
  }
}
