import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top curved container
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade800, Colors.teal.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Bottom curved container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade800],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // Main content
          user == null
              ? const Center(
                  child: Text(
                    'Please log in to view favorites',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Favorites',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 3,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: firestore.collection('users').doc(user.uid).snapshots(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'Error loading favorites',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!userSnapshot.data!.exists) {
                              return const Center(
                                child: Text(
                                  'No favorites found',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            final favorites =
                                List<String>.from(userSnapshot.data!.get('favorites') ?? []);

                            if (favorites.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No favorites added yet',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return StreamBuilder<QuerySnapshot>(
                              stream: firestore
                                  .collection('properties')
                                  .where('title', whereIn: favorites)
                                  .snapshots(),
                              builder: (context, propSnapshot) {
                                if (propSnapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      'Error loading properties',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }
                                if (propSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final properties = propSnapshot.data!.docs;

                                if (properties.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No matching properties found',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                                  itemCount: properties.length,
                                  itemBuilder: (context, index) {
                                    final property = properties[index].data() as Map<String, dynamic>;
                                    final title = property['title'] ?? 'No Title';
                                    final price = property['price']?.toString() ?? 'N/A';
                                    final imageUrl = property['imageUrl'] ?? '';
                                    final location = property['location'] ?? 'Unknown Location';
                                    final size = property['size']?.toString() ?? 'N/A';
                                    final description = property['description'] ?? 'No description available';
                                    final amenities = List<String>.from(property['amenities'] ?? []);

                                    // Log the image URL for debugging
                                    print('Image URL for $title: $imageUrl');

                                    return AnimatedOpacity(
                                      opacity: 1.0,
                                      duration: Duration(milliseconds: 300 + (index * 100)),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PropertyDetailPage(property: property),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          margin: const EdgeInsets.symmetric(vertical: 12),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.teal.shade50, Colors.teal.shade100],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Image and Title Row
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Property Image
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(15),
                                                        child: imageUrl.isNotEmpty
                                                            ? Image.network(
                                                                imageUrl,
                                                                width: 100,
                                                                height: 100,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  print('Image load error for $imageUrl: $error');
                                                                  return Container(
                                                                    width: 100,
                                                                    height: 100,
                                                                    color: Colors.teal.shade100,
                                                                    child: Icon(
                                                                      Icons.home,
                                                                      color: Colors.teal.shade600,
                                                                      size: 50,
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : Container(
                                                                width: 100,
                                                                height: 100,
                                                                color: Colors.teal.shade100,
                                                                child: Icon(
                                                                  Icons.home,
                                                                  color: Colors.teal.shade600,
                                                                  size: 50,
                                                                ),
                                                              ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      // Title and Price
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: const TextStyle(
                                                                fontFamily: 'Poppins',
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 20,
                                                                color: Colors.black87,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              '\$$price',
                                                              style: TextStyle(
                                                                fontFamily: 'Roboto',
                                                                fontSize: 16,
                                                                color: Colors.teal.shade700,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // Additional Details
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        color: Colors.grey.shade600,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          location,
                                                          style: TextStyle(
                                                            fontFamily: 'Roboto',
                                                            fontSize: 14,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.square_foot,
                                                        color: Colors.grey.shade600,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$size sq ft',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 14,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Description:',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    description,
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (amenities.isNotEmpty) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Amenities:',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 4,
                                                      children: amenities
                                                          .map(
                                                            (amenity) => Chip(
                                                              label: Text(
                                                                amenity,
                                                                style: const TextStyle(
                                                                  fontFamily: 'Roboto',
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              backgroundColor: Colors.teal.shade100,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(20),
                                                              ),
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 8, vertical: 0),
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 12),
                                                  // Remove from Favorites Button
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: OutlinedButton.icon(
                                                      onPressed: () {
                                                        _showRemoveConfirmationDialog(
                                                          context,
                                                          firestore,
                                                          user.uid,
                                                          title,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color: Colors.red.shade400,
                                                        size: 20,
                                                      ),
                                                      label: const Text(
                                                        'Remove',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 14,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      style: OutlinedButton.styleFrom(
                                                        side: BorderSide(color: Colors.red.shade400),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 16, vertical: 8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _showRemoveConfirmationDialog(
      BuildContext context, FirebaseFirestore firestore, String userId, String propertyTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Favorite',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "$propertyTitle" from your favorites?',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await firestore.collection('users').doc(userId).update({
                  'favorites': FieldValue.arrayRemove([propertyTitle]),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Removed from favorites'),
                    backgroundColor: Colors.green.shade400,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error removing favorite: $e'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for Property Detail Page
class PropertyDetailPage extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          property['title'] ?? 'Property Details',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.teal.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details for ${property['title']}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: \$${property['price']?.toString() ?? 'N/A'}',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${property['location'] ?? 'Unknown'}',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for top curve
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.3, size.height, size.width * 0.6, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.4, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom clipper for bottom curve
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width * 0.3, 0, size.width * 0.5, 30);
    path.quadraticBezierTo(size.width * 0.7, 60, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
