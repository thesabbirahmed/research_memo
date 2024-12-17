import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// Screens
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'forget_password_screen.dart';
import 'user_homepage.dart';
import 'profile_screen.dart';
import 'revision_planning_screen.dart';
import 'ai_recommendations_screen.dart';
import 'quizzes_screen.dart';
import 'progress_tracking_screen.dart';
import 'resources_screen.dart';
import 'gamification_screen.dart';
import 'time_tools_screen.dart';
import 'mindfulness_screen.dart';
import 'edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Use ValueNotifier for dynamic theme management
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(ThemeMode.system);

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  /// Load Theme Preference from SharedPreferences
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeModeNotifier.value = ThemeMode.values[themeIndex];
  }

  /// Update Theme Preference and Save to SharedPreferences
  Future<void> _updateTheme(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
    _themeModeNotifier.value = themeMode; // Update theme dynamically
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Study Planner App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode, // Apply selected theme dynamically
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignUpScreen(),
            '/forgetPassword': (context) => ForgetPasswordScreen(),
            '/userHomepage': (context) => UserHomepage(),
            '/profile': (context) => ProfileScreen(),
            '/settings': (context) => SettingsScreen(onThemeChanged: _updateTheme),
            '/revisionPlanning': (context) => RevisionPlanningScreen(),
            '/aiRecommendations': (context) => AIRecommendationsScreen(),
            '/quizzes': (context) => QuizzesScreen(),
            '/progressTracking': (context) => ProgressTrackingScreen(),
            '/resources': (context) => ResourcesScreen(),
            '/gamification': (context) => GamificationScreen(),
            '/timeTools': (context) => TimeToolsScreen(),
            '/mindfulness': (context) => MindfulnessScreen(),
            '/editProfile': (context) => EditProfileScreen(),
          },
        );
      },
    );
  }
}
 