import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomepage extends StatefulWidget {
  @override
  _UserHomepageState createState() => _UserHomepageState();
}

class _UserHomepageState extends State<UserHomepage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String userName = "User";
  String profileImage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final userData = await firestore.collection('users').doc(user.uid).get();
        setState(() {
          userName = userData['name'] ?? 'User';
          profileImage = userData['profileImage'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    Expanded( // Add Expanded to avoid overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $userName!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Never Force Learning!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Features Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    FeatureCard(
                      title: 'Revision Planning',
                      icon: Icons.schedule,
                      backgroundColor: Colors.orange,
                      onPressed: () {
                        Navigator.pushNamed(context, '/revisionPlanning');
                      },
                    ),
                    FeatureCard(
                      title: 'AI Recommendations',
                      icon: Icons.lightbulb,
                      backgroundColor: Colors.yellow,
                      onPressed: () {
                        Navigator.pushNamed(context, '/aiRecommendations');
                      },
                    ),
                    FeatureCard(
                      title: 'Quizzes',
                      icon: Icons.quiz,
                      backgroundColor: Colors.teal,
                      onPressed: () {
                        Navigator.pushNamed(context, '/quizzes');
                      },
                    ),
                    FeatureCard(
                      title: 'Progress Tracking',
                      icon: Icons.bar_chart,
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        Navigator.pushNamed(context, '/progressTracking');
                      },
                    ),
                    FeatureCard(
                      title: 'Resources',
                      icon: Icons.library_books,
                      backgroundColor: Colors.purple,
                      onPressed: () {
                        Navigator.pushNamed(context, '/resources');
                      },
                    ),
                    FeatureCard(
                      title: 'Gamification',
                      icon: Icons.star,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        Navigator.pushNamed(context, '/gamification');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "progress",
              onPressed: () {
                Navigator.pushNamed(context, '/progressTracking');
              },
              tooltip: 'Progress',
              child: Icon(Icons.track_changes),
            ),
            FloatingActionButton(
              heroTag: "profile",
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              tooltip: 'Profile',
              child: Icon(Icons.person),
            ),
            FloatingActionButton(
              heroTag: "settings",
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              tooltip: 'Settings',
              child: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}

// FeatureCard Widget
class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  FeatureCard({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: backgroundColor,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
