import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_property_page.dart'; // Import Add Property Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to store properties
  List<Map<String, dynamic>> _properties = [];

  @override
  void initState() {
    super.initState();
    // Fetch the latest properties on startup
    _fetchProperties();
  }

  // Fetch the latest 5 properties from Firestore
  Future<void> _fetchProperties() async {
    try {
      final querySnapshot = await _firestore
          .collection('properties')
          .orderBy('from', descending: true) // Order by 'from' field or 'timestamp'
          .limit(5) // Limit to the latest 5 properties
          .get();

      setState(() {
        _properties = querySnapshot.docs.map((doc) {
          return {
            'title': doc['title'],
            'bed': doc['bed'],
            'bath': doc['bath'],
            'rent': doc['rent'],
            'location': doc['location'],
            'owner': doc['owner'],
            'phone': doc['phone'],
            'lat': doc['lat'],
            'lng': doc['lng'],
            'image_url': doc['image_url'], // 'image_url' will be retrieved as a string
            'from': doc['from'], // 'from' will be retrieved as a string
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[50],
        elevation: 0.5,
        title: const Text(
          'Rento',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _properties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final property = _properties[index];
                print('Image URL: ${property['image_url']}');  // Debugging output to check the URL
                return GestureDetector(
                  onTap: () {
                    // Navigate to Property Details (You can implement this functionality)
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        property['image_url'] != null && property['image_url'].isNotEmpty
                            ? Image.network(
                                property['image_url'], // Display the image URL
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                              )
                            : const Image(
                                image: AssetImage('assets/images/placeholder.png'), // Placeholder if image URL is missing
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property['title'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  '🛏 Bed: ${property['bed']}   🚿 Bath: ${property['bath']}'),
                              Text('📅 Available from: ${property['from']}'),
                              const SizedBox(height: 8),
                              Text(
                                '💸 Rent: ${property['rent']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '📍 ${property['location']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: 'Add Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // Navigate to Add Property Page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddPropertyPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
