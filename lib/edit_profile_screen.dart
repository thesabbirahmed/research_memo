import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController subjectsController = TextEditingController();
  final TextEditingController profileImageController = TextEditingController();

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
        throw Exception("Profile does not exist in Firestore.");
      }

      setState(() {
        nameController.text = profile['name'] ?? '';
        ageController.text = profile['age'] ?? '';
        institutionController.text = profile['institution'] ?? '';
        gradeController.text = profile['grade'] ?? '';
        subjectsController.text = profile['subjects'] ?? '';
        profileImageController.text = profile['profileImage'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile. Error: $e")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> updateProfile() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      await firestore.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        'age': ageController.text.trim(),
        'institution': institutionController.text.trim(),
        'grade': gradeController.text.trim(),
        'subjects': subjectsController.text.trim(),
        'profileImage': profileImageController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully.")),
      );

      Navigator.pop(context); // Return to the profile screen
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile. Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: institutionController,
                decoration: InputDecoration(
                  labelText: 'Institution',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: gradeController,
                decoration: InputDecoration(
                  labelText: 'Grade/Study Level',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: subjectsController,
                decoration: InputDecoration(
                  labelText: 'Subjects of Interest',
                  hintText: 'E.g., Math, Science, History',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: profileImageController,
                decoration: InputDecoration(
                  labelText: 'Profile Image URL',
                  hintText: 'Enter a valid image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProfile,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
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
}
