import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 

// --- CONFIG ---
import 'config/theme_manager.dart'; // REQUIRED: Import the theme manager we just made

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
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WRAP EVERYTHING IN ValueListenableBuilder
    // This listens to the themeNotifier variable. When it changes (true/false),
    // the whole app rebuilds with the new mode!
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'FitLife Pro',
          debugShowCheckedModeBanner: false,
          
          // 1. LIGHT THEME CONFIGURATION
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            fontFamily: 'Roboto',
          ),
          
          // 2. DARK THEME CONFIGURATION
          darkTheme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212), // Very dark grey
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: Colors.grey[850],
            dialogBackgroundColor: Colors.grey[800],
            fontFamily: 'Roboto',
          ),

          // 3. ACTUAL SWITCH LOGIC
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // 4. ROUTES
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => const LoginWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            
            '/home': (context) => const DashboardScreen(),
            '/activity_list': (context) => const ActivityListScreen(),
            '/add_activity': (context) => const AddActivityScreen(),
            
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/body_metrics': (context) => const BodyMetricsScreen(),
          },
        );
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
        if (snapshot.hasData) {
          return const DashboardScreen(); 
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}