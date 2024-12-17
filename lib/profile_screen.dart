import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = "Unknown";
  String age = "Unknown";
  String institution = "Unknown";
  String grade = "Unknown";
  String subjects = "Unknown";
  String profileImage = ""; // URL for the profile image

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final profile = await firestore.collection('users').doc(user.uid).get();

      if (!profile.exists) {
        throw Exception("User profile does not exist.");
      }

      setState(() {
        name = profile['name'] ?? 'Unknown';
        age = profile['age'] ?? 'Unknown';
        institution = profile['institution'] ?? 'Unknown';
        grade = profile['grade'] ?? 'Unknown';
        subjects = profile['subjects'] ?? 'Unknown';
        profileImage = profile['profileImage'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile. Please try again.")),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 60,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              SizedBox(height: 20),

              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileDetailRow('Full Name', name),
                      Divider(),
                      _buildProfileDetailRow('Age', age),
                      Divider(),
                      _buildProfileDetailRow('Institution', institution),
                      Divider(),
                      _buildProfileDetailRow('Grade/Study Level', grade),
                      Divider(),
                      _buildProfileDetailRow('Subjects of Interest', subjects),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/editProfile').then((_) {
                    setState(() {
                      isLoading = true;
                    });
                    fetchUserProfile();
                  });
                },
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to display user details
  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
