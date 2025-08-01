import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addpets extends StatefulWidget {
  const Addpets({super.key, required Map pet});

  @override
  State<Addpets> createState() => _AddpetsState();
}

class _AddpetsState extends State<Addpets> {
  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController petDescriptionController =
      TextEditingController();

  // Error message variables for validation
  String? nameError;
  String? heightError;
  String? weightError;
  String? priceError;
  String? addressError;
  String? categoryError;
  String? breedError;
  String? ageError;
  String? genderError;
  String? locationError;
  String? petDescriptionError;

  // Variables for dropdown display names (nullable for initial hint state)
  String? selectedCategory;
  String? selectedBreed;
  String? selectedGender;
  String? selectedLocation;

  // Variables to store the ACTUAL IDs for API submission
  String selectedCategoryId = '';
  String selectedBreedId = '';
  String selectedLocationId = '';

  String? token; // Authentication token

  File? _pickedImage; // Stores the image file picked from gallery
  final ImagePicker picker = ImagePicker(); // Image picker instance
  XFile? file; // XFile object from image picker

  // --- Initialization ---
  @override
  void initState() {
    super.initState();
    _initializeData(); // Call a single async method for all initialization tasks
  }

  // Handles asynchronous data loading (like token and initial API calls)
  Future<void> _initializeData() async {
    await _loadToken(); // Ensure token is loaded first
    if (token != null && token!.isNotEmpty) {
      await _fetchCategories(); // Await category fetching
      await _fetchLocations(); // Await location fetching
    } else {
      debugPrint('Authentication token is missing. Please log in.');
      if (mounted) {
        // Check if the widget is still in the tree before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Authentication token missing. Please log in.')),
        );
      }
      // You might want to navigate to a login screen here
    }
  }

  // --- Image Picking ---
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        file = pickedFile;
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // --- Utility for showing snackbars ---
  void _showSnackBar(String message) {
    if (mounted) {
      // Ensure widget is still mounted
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // --- API Calls ---

  // Sends pet data to the backend
  Future<void> _sendPetData() async {
    // Basic validation before sending
    if (_pickedImage == null) {
      _showSnackBar("Please select an image for the pet.");
      return;
    }

    // Explicitly validate all dropdowns before sending
    setState(() {
      categoryError = _validateCategory(selectedCategory);
      breedError = _validateBreed(selectedBreed);
      genderError = _validateGender(selectedGender);
      locationError = _validateLocation(selectedLocation);
    });

    if (categoryError != null ||
        breedError != null ||
        genderError != null ||
        locationError != null) {
      _showSnackBar("Please fill all required dropdown values.");
      return;
    }

    final url = Uri.parse("http://192.168.1.35/Empetz/api/v1/pet");
    var request = http.MultipartRequest('POST', url);

    // Add authorization header
    if (token == null || token!.isEmpty) {
      _showSnackBar("Authentication token is missing. Cannot send data.");
      return;
    }
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['Name'] = nameController.text.trim();
    request.fields['height'] = heightController.text.trim();
    request.fields['Price'] = priceController.text.trim();
    request.fields['Address'] = addressController.text.trim();
    request.fields['Discription'] = petDescriptionController.text.trim();
    request.fields['weight'] = weightController.text.trim();
    request.fields['Age'] = ageController.text.trim();
    request.fields['BreedId'] = selectedBreedId;
    request.fields['LocationId'] = selectedLocationId;
    request.fields['CategoryId'] = selectedCategoryId;
    request.fields['Gender'] =
        selectedGender!; // ! is safe here due to prior validation

    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath('ImageFile', _pickedImage!.path),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Pet added successfully!');
        // Pop back to the previous screen (HOMESCREEN) and pass 'true' as a result
        // This 'true' will tell HOMESCREEN to refresh its pet list.
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        String errorMessage =
            'Failed to add pet. Status: ${response.statusCode}';
        try {
          final decodedBody = json.decode(responseBody);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            errorMessage = decodedBody['message'];
          } else if (decodedBody is Map && decodedBody.containsKey('error')) {
            errorMessage = decodedBody['error'];
          }
        } catch (e) {
          debugPrint("Could not parse error response body as JSON: $e");
        }
        _showSnackBar(errorMessage);
      }
    } on SocketException {
      _showSnackBar(
          "No internet connection or server unreachable. Please check your network.");
    } catch (e) {
      debugPrint("Error sending pet data: $e");
      _showSnackBar("An unexpected error occurred: $e");
    }
  }

  List<dynamic> categories = [];
  List<dynamic> breeds = [];
  List<dynamic> locations = [];

  // Loads authentication token from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token =
          prefs.getString('token'); // 'token' should match where you store it
    });
  }

  // Fetches locations from the backend
  Future<void> _fetchLocations() async {
    if (token == null || token!.isEmpty)
      return; // Don't fetch if token is missing
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.35/Empetz/api/v1/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          locations = json.decode(response.body);
        });
      } else {
        debugPrint('Failed to load locations: ${response.statusCode}');
        setState(() {
          locations = [];
        });
        _showSnackBar('Failed to load locations.');
      }
    } on SocketException {
      _showSnackBar('Network error while fetching locations.');
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      setState(() {
        locations = [];
      });
      _showSnackBar('Error fetching locations.');
    }
  }

  // Fetches categories from the backend
  Future<void> _fetchCategories() async {
    if (token == null || token!.isEmpty)
      return; // Don't fetch if token is missing
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
          categories = json.decode(response.body);
        });
      } else {
        debugPrint('Failed to load categories: ${response.statusCode}');
        setState(() {
          categories = [];
        });
        _showSnackBar('Failed to load categories.');
      }
    } on SocketException {
      _showSnackBar('Network error while fetching categories.');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() {
        categories = [];
      });
      _showSnackBar('Error fetching categories.');
    }
  }

  // Fetches breeds based on selected category ID
  Future<void> _fetchBreeds(String categoryId) async {
    if (token == null || token!.isEmpty)
      return; // Don't fetch if token is missing
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.35/Empetz/api/v1/breed/category/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          breeds = json.decode(response.body);
          selectedBreed = null; // Reset breed selection when category changes
          selectedBreedId = ''; // Reset breed ID when category changes
        });
      } else {
        debugPrint('Failed to load breeds: ${response.statusCode}');
        setState(() {
          breeds = [];
          selectedBreed = null;
          selectedBreedId = '';
        });
        _showSnackBar('Failed to load breeds for the selected category.');
      }
    } on SocketException {
      _showSnackBar('Network error while fetching breeds.');
    } catch (e) {
      debugPrint('Error fetching breeds: $e');
      setState(() {
        breeds = [];
        selectedBreed = null;
        selectedBreedId = '';
      });
      _showSnackBar('Error fetching breeds.');
    }
  }

  // --- Validation Methods ---

  String? _validateName(String? name) {
    if (name == null || name.isEmpty) return 'Name cannot be empty';
    if (RegExp(r'[!@#<>?":_~;[\]\\|=+(*&^%0-9-)]').hasMatch(name)) {
      return 'Name must not contain special characters or numbers';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  String? _validateBreed(String? value) {
    // Check both display value and ID for robustness
    if (value == null || value.isEmpty || selectedBreedId.isEmpty) {
      return 'Please select a breed';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age cannot be empty';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number for age';
    }
    if (int.parse(value) <= 0) {
      return 'Age must be greater than 0';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a gender';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a location';
    }
    return null;
  }

  String? _validateHeight(String? height) =>
      (height == null || height.isEmpty) ? 'Height cannot be empty' : null;
  String? _validateWeight(String? weight) =>
      (weight == null || weight.isEmpty) ? 'Weight cannot be empty' : null;
  String? _validatePrice(String? price) =>
      (price == null || price.isEmpty) ? 'Price cannot be empty' : null;
  String? _validateAddress(String? address) =>
      (address == null || address.isEmpty) ? 'Address cannot be empty' : null;

  String? _validatePetDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Pet description cannot be empty';
    }
    if (description.length < 10) {
      return 'Description must be at least 10 characters long';
    }
    return null;
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Pet Details',
          style: TextStyle(
              fontFamily: 'Chokokutai',
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 91, 4, 241),
                Colors.pink,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Card(
                  elevation: 5,
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Center(
                      child: file == null
                          ? IconButton(
                              onPressed:
                                  _pickImage, // Use the correct _pickImage
                              icon: const Icon(Icons.add_a_photo_outlined,
                                  size: 50, color: Colors.grey),
                              tooltip: 'Pick an image',
                            )
                          : Stack(
                              children: [
                                Image.file(
                                  File(file!.path),
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.change_circle,
                                        color: Colors.white, size: 30),
                                    onPressed:
                                        _pickImage, // Allow changing image
                                    tooltip: 'Change image',
                                  ),
                                )
                              ],
                            ),
                    ),
                  )),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Enter Name',
                  errorText: nameError,
                ),
                onChanged: (value) =>
                    setState(() => nameError = _validateName(value)),
              ),
            ),
            const SizedBox(height: 10),

            // --- Category Dropdown ---
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline:
                            const SizedBox(), // Remove the default underline
                        hint: const Text('Select Category',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        value: selectedCategory,
                        items: categories.isNotEmpty
                            ? categories
                                .map<DropdownMenuItem<String>>((category) {
                                final String catName = category['name'] ?? '';
                                return DropdownMenuItem<String>(
                                  value: catName,
                                  child: Text(catName),
                                );
                              }).toList()
                            : [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  enabled: false,
                                  child: Text('No categories available'),
                                )
                              ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            categoryError = _validateCategory(selectedCategory);
                            final selectedCatObj = categories.firstWhere(
                              (cat) => cat['name'] == selectedCategory,
                              orElse: () => null,
                            );
                            if (selectedCatObj != null) {
                              selectedCategoryId =
                                  selectedCatObj['id'].toString();
                              _fetchBreeds(selectedCategoryId);
                            } else {
                              breeds = [];
                              selectedBreed = null;
                              selectedBreedId = '';
                            }
                          });
                        },
                      ),
                    ),
                    if (categoryError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                        child: Text(
                          categoryError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Breed Dropdown ---
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Select Breed',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        value: selectedBreed,
                        items: breeds.isNotEmpty
                            ? breeds.map<DropdownMenuItem<String>>((breed) {
                                final String breedName = breed['name'] ?? '';
                                return DropdownMenuItem<String>(
                                  value: breedName,
                                  child: Text(breedName),
                                );
                              }).toList()
                            : [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  enabled: false,
                                  child: Text('No breeds available'),
                                )
                              ],
                        onChanged: (value) {
                          setState(() {
                            selectedBreed = value;
                            breedError = _validateBreed(selectedBreed);
                            final selectedBreedObj = breeds.firstWhere(
                              (breed) => breed['name'] == selectedBreed,
                              orElse: () => null,
                            );
                            if (selectedBreedObj != null) {
                              selectedBreedId =
                                  selectedBreedObj['id'].toString();
                            } else {
                              selectedBreedId = '';
                            }
                          });
                        },
                      ),
                    ),
                    if (breedError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                        child: Text(
                          breedError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Gender Dropdown ---
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: selectedGender,
                        hint: const Text('Select Gender',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        items: <String>[
                          'Male',
                          'Female',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                            genderError = _validateGender(selectedGender);
                          });
                        },
                      ),
                    ),
                    if (genderError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                        child: Text(
                          genderError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Location Dropdown ---
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Select Location',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        value: selectedLocation,
                        items: locations.isNotEmpty
                            ? locations
                                .map<DropdownMenuItem<String>>((location) {
                                final String locationName =
                                    location['name'] ?? '';
                                return DropdownMenuItem<String>(
                                  value: locationName,
                                  child: Text(locationName),
                                );
                              }).toList()
                            : [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  enabled: false,
                                  child: Text('No locations available'),
                                )
                              ],
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                            locationError = _validateLocation(selectedLocation);
                            final selectedLocationObj = locations.firstWhere(
                              (loc) => loc['name'] == selectedLocation,
                              orElse: () => null,
                            );
                            if (selectedLocationObj != null) {
                              selectedLocationId =
                                  selectedLocationObj['id'].toString();
                            } else {
                              selectedLocationId = '';
                            }
                          });
                        },
                      ),
                    ),
                    if (locationError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                        child: Text(
                          locationError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: ageController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Age',
                  errorText: ageError,
                  
                ),
                onChanged: (value) =>
                    setState(() => ageError = _validateAge(value)),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: heightController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Height',
                  errorText: heightError,
              
                ),
                onChanged: (value) =>
                    setState(() => heightError = _validateHeight(value)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: weightController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Weight',
                  errorText: weightError,
                 
                ),
                onChanged: (value) =>
                    setState(() => weightError = _validateWeight(value)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: priceController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Price',
                  errorText: priceError,
                 
                ),
                onChanged: (value) =>
                    setState(() => priceError = _validatePrice(value)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: petDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Pet Description',
                  alignLabelWithHint: true,
                  errorText: petDescriptionError,
                  
                ),
                onChanged: (value) => setState(
                    () => petDescriptionError = _validatePetDescription(value)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelText: 'Address',
                  alignLabelWithHint: true,
                  errorText: addressError,
                 
                ),
                onChanged: (value) =>
                    setState(() => addressError = _validateAddress(value)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 91, 4, 241),
                        Colors.pink,
                      ],
                    )),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    fixedSize: const Size(200, 30),
                  ),
                  onPressed: () async {
                    // Trigger all validations on button press
                    setState(() {
                      nameError = _validateName(nameController.text);
                      heightError = _validateHeight(heightController.text);
                      weightError = _validateWeight(weightController.text);
                      priceError = _validatePrice(priceController.text);
                      addressError = _validateAddress(addressController.text);
                      categoryError = _validateCategory(selectedCategory);
                      breedError = _validateBreed(selectedBreed);
                      ageError = _validateAge(ageController.text);
                      genderError = _validateGender(selectedGender);
                      locationError = _validateLocation(selectedLocation);
                      petDescriptionError = _validatePetDescription(
                          petDescriptionController.text);
                    });

                    // Check if all error messages are null (i.e., no errors)
                    if (nameError == null &&
                        heightError == null &&
                        weightError == null &&
                        priceError == null &&
                        addressError == null &&
                        categoryError == null &&
                        breedError == null &&
                        ageError == null &&
                        genderError == null &&
                        locationError == null &&
                        petDescriptionError == null) {
                      await _sendPetData(); // Send data only if all validations pass
                    } else {
                      _showSnackBar('Please fill all fields correctly');
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
