import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user's ID
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Progress Tracking'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Text(
            "No user is currently logged in.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Tracking'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              _buildHeaderCard(),
              SizedBox(height: 10),
              _buildStudyTechniquesSection(userId),
              SizedBox(height: 20),
              _buildResourcePlanningChart(userId),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Card for Progress Tracking
  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueAccent,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.white, size: 40),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'My Progress',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Study Techniques Section
  Widget _buildStudyTechniquesSection(String userId) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Techniques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('results').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data.'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No quiz results available.'));
                }

                final Map<String, dynamic> resultsData =
                snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  children: resultsData.entries.map((entry) {
                    String subject = entry.key;
                    String technique =
                        entry.value['recommendedTechnique'] ?? 'Not Available';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(Icons.school, color: Colors.blueAccent),
                        title: Text(
                          subject,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: Text(
                          'Technique: $technique',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Resource Planning Summary Chart
  Widget _buildResourcePlanningChart(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('revisions')
          .doc(userId)
          .collection('plans')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final plans = snapshot.data!.docs;

        // Safely count priority levels with fallback values
        int high = plans.where((e) => (e.data() as Map<String, dynamic>?)?['priority'] == 'High').length;
        int medium = plans.where((e) => (e.data() as Map<String, dynamic>?)?['priority'] == 'Medium').length;
        int low = plans.where((e) => (e.data() as Map<String, dynamic>?)?['priority'] == 'Low').length;

        final List<ChartData> chartData = [
          ChartData('High', high, Colors.redAccent),
          ChartData('Medium', medium, Colors.orangeAccent),
          ChartData('Low', low, Colors.greenAccent),
        ];

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work to Do: Revision Planning',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap),
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
