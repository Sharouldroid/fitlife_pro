import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/activity/add_activity_screen.dart';
import '../screens/activity/activity_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home'; // Dashboard
  static const String activityList = '/activity_list';
  static const String addActivity = '/add_activity';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const DashboardScreen(),
      activityList: (context) => const ActivityListScreen(),
      addActivity: (context) => const AddActivityScreen(),
      profile: (context) => const ProfileScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }
}