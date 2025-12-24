import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Ensure you have this file, or follow the note below

// --- AUTH SCREENS ---
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';

// --- HOME & ACTIVITY SCREENS ---
import 'screens/home/dashboard_screen.dart';
import 'screens/activity/activity_list_screen.dart';
import 'screens/activity/add_activity_screen.dart';

// --- PROFILE SCREENS ---
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/body_metrics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // If you DO NOT have firebase_options.dart, remove 'options: ...' and just use await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLife Pro',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),

      // 1. Set the first screen to show (Splash)
      initialRoute: '/splash',

      // 2. Define ALL your routes here in one place
      routes: {
        // Splash Screen (First Page)
        '/splash': (context) => const SplashScreen(),

        // The "Wrapper" decides if user goes to Dashboard or Login
        '/': (context) => const LoginWrapper(),

        // Auth Routes
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Main App Routes
        '/home': (context) => const DashboardScreen(),
        '/activity_list': (context) => const ActivityListScreen(),
        '/add_activity': (context) => const AddActivityScreen(),
        
        // Profile & Settings
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/body_metrics': (context) => const BodyMetricsScreen(),
      },
    );
  }
}

// This widget listens to Firebase Auth changes
class LoginWrapper extends StatelessWidget {
  const LoginWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, the user is logged in
        if (snapshot.hasData) {
          return const DashboardScreen(); 
        } 
        // Otherwise, they are logged out
        else {
          return const LoginScreen();
        }
      },
    );
  }
}