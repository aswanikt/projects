// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:empetz/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }





































































// import 'dart:convert';
// import 'package:empetz/about.dart';
// import 'package:empetz/addpets.dart';
// import 'package:empetz/contact.dart';
// import 'package:empetz/Account.dart';
// import 'package:empetz/favorite.dart';
// import 'package:empetz/notificationscreen.dart';
// import 'package:empetz/pets.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class HOMESCREEN extends StatefulWidget {
//   const HOMESCREEN({super.key});

//   @override
//   State<HOMESCREEN> createState() => _HOMESCREENState();
// }

// class _HOMESCREENState extends State<HOMESCREEN> {
//   List<dynamic> category = [];
//   List<dynamic> petcategory = [];
//   String userName = '';
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     fetchdata();
//     petdata();
//     getUserData();
//   }

//   Future<void> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userName = prefs.getString('userName') ?? 'User';
//       userId = prefs.getString('userId');
//     });
//   }

//   Future<void> fetchdata() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     if (token.isEmpty) return;

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.35/Empetz/api/v1/category'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           category = json.decode(response.body);
//         });
//       }
//     } catch (e) {
//       debugPrint('Category fetch error: $e');
//     }
//   }

//   Future<void> petdata() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     if (token.isEmpty) return;

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.35/Empetz/api/v1/user-posted-history'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           petcategory = json.decode(response.body);
//         });
//       }
//     } catch (e) {
//       debugPrint('Pet data fetch error: $e');
//     }
//   }

//   Future<void> deletePet(String petId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     if (token.isEmpty) return;

//     try {
//       final response = await http.delete(
//         Uri.parse('http://192.168.1.35/Empetz/api/v1/pet/$petId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Pet deleted successfully")),
//         );
//         await petdata();
//       }
//     } catch (e) {
//       debugPrint("Delete error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: Colors.white),
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color.fromARGB(255, 91, 4, 241), Colors.pink],
//               ),
//             ),
//           ),
//           title: Text(
//             "Home",
//             style: TextStyle(
//               fontFamily: 'Chokokutai',
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 30,
//             ),
//           ),
//           centerTitle: true,
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => NOTIFICATION()),
//                 );
//               },
//               icon: Icon(Icons.notifications, color: Colors.white),
//             ),
//           ],
//           bottom: TabBar(
//             tabs: [
//               Text('BUYER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//               Text('SELLER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
//             ],
//           ),
//         ),
//         drawer: Drawer(
//           elevation: 50,
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color.fromARGB(255, 91, 4, 241), Colors.pink],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: AssetImage('assets/person.png'),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       userName,
//                       style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     if (userId != null)
//                       Text(
//                         'ID: $userId',
//                         style: TextStyle(color: Colors.white70, fontSize: 14),
//                       ),
//                   ],
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   leading: Icon(Icons.account_circle),
//                   title: Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
//                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Account())),
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   leading: Icon(Icons.favorite_sharp),
//                   title: Text('Favorite', style: TextStyle(fontWeight: FontWeight.bold)),
//                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Favorite())),
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   leading: Icon(Icons.question_mark_rounded),
//                   title: Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
//                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => About())),
//                 ),
//               ),
//               Card(
//                 child: ListTile(
//                   leading: Icon(Icons.contacts),
//                   title: Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
//                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Contact())),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             category.isEmpty
//                 ? Center(child: CircularProgressIndicator())
//                 : GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9),
//                     itemCount: category.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => Pets(
//                               categoryId: category[index]['id'],
//                               categoryName: category[index]['name'],
//                             ),
//                           ),
//                         ),
//                         child: Card(
//                           margin: EdgeInsets.all(8.0),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           elevation: 4,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 45,
//                                 backgroundImage: NetworkImage(category[index]['imagePath'] ?? ''),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 category[index]['name'] ?? 'Category',
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//             Stack(
//               children: [
//                 petcategory.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.pets, size: 60, color: Colors.grey[400]),
//                             SizedBox(height: 10),
//                             Text("No pets posted yet. Click '+' to add one!", style: TextStyle(fontSize: 16)),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: EdgeInsets.only(bottom: 80),
//                         itemCount: petcategory.length,
//                         itemBuilder: (context, index) {
//                           final pet = petcategory[index];
//                           final name = pet['name'] ?? 'Unnamed Pet';
//                           final price = pet['price']?.toString() ?? 'N/A';
//                           final id = pet['id'].toString();
//                           final imageBase64 = pet['image'];

//                           ImageProvider? petImage;
//                           if (imageBase64 != null && imageBase64.isNotEmpty) {
//                             try {
//                               petImage = MemoryImage(base64Decode(imageBase64));
//                             } catch (_) {
//                               petImage = AssetImage('assets/placeholder_pet.png');
//                             }
//                           }

//                           return Card(
//                             margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             elevation: 4,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 40,
//                                     backgroundImage: petImage ?? AssetImage('assets/placeholder_pet.png'),
//                                   ),
//                                   SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                                         SizedBox(height: 8),
//                                         Text('Price: ₹$price', style: TextStyle(fontSize: 16, color: Colors.green[700])),
//                                       ],
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => deletePet(id),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                 Positioned(
//                   bottom: 16,
//                   right: 16,
//                   child: FloatingActionButton(
//                     onPressed: () async {
//                       final result = await Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => Addpets(pet: {})),
//                       );
//                       if (result == true) {
//                         petdata();
//                       }
//                     },
//                     backgroundColor: const Color.fromARGB(255, 91, 4, 241),
//                     child: Icon(Icons.add, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
