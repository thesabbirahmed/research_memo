import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class RevisionPlanningScreen extends StatefulWidget {
  @override
  _RevisionPlanningScreenState createState() => _RevisionPlanningScreenState();
}

class _RevisionPlanningScreenState extends State<RevisionPlanningScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  /// Initialize notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Schedule a notification
  Future<void> _scheduleNotification(String subject, DateTime date) async {
    final androidDetails = AndroidNotificationDetails(
      'revision_reminders',
      'Revision Reminders',
      channelDescription: 'Scheduled reminders for revisions',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      'Revision Reminder',
      'Don\'t forget to revise $subject!',
      tz.TZDateTime.from(date, tz.local).add(Duration(seconds: 5)),
      NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Add a revision plan
  void _addRevisionPlan() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null && _subjectController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('revisions')
          .doc(userId)
          .collection('plans')
          .add({
        'subject': _subjectController.text,
        'date': _selectedDate.toIso8601String(),
        'notes': _notesController.text,
        'priority': _selectedPriority,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _scheduleNotification(_subjectController.text, _selectedDate);

      _subjectController.clear();
      _notesController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Revision Plan Added Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields.')),
      );
    }
  }

  /// Mark a revision as completed
  void _markAsCompleted(String planId) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('revisions')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .update({'status': 'Completed'});
    }
  }

  /// Build revision list
  Widget _buildRevisionList() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return Center(child: Text('No user logged in.'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('revisions')
          .doc(userId)
          .collection('plans')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final plans = snapshot.data!.docs;

        int completed = plans.where((e) => e['status'] == 'Completed').length;
        int total = plans.length;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final data = plan.data() as Map<String, dynamic>;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(data['subject'] ?? 'No Subject'),
                    subtitle: Text(
                      'Date: ${data['date']?.split('T')[0] ?? ''}\n'
                          'Priority: ${data['priority'] ?? 'Medium'}\n'
                          'Status: ${data['status']}',
                    ),
                    trailing: data['status'] == 'Pending'
                        ? IconButton(
                      icon: Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      onPressed: () => _markAsCompleted(plan.id),
                    )
                        : Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revision Planning'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar
            TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDate,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(labelText: 'Subject'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(labelText: 'Notes'),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    items: ['High', 'Medium', 'Low']
                        .map((e) => DropdownMenuItem(
                        value: e, child: Text('Priority: $e')))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPriority = value!);
                    },
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addRevisionPlan,
                    child: Text('Add Revision Plan'),
                  ),
                ],
              ),
            ),
            _buildRevisionList(),
          ],
        ),
      ),
    );
  }
}
