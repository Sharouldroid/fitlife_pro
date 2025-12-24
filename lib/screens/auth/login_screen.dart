import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
// IMPORT CUSTOM WIDGETS
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Use Controllers for CustomTextField
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String error = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background color handled by Theme
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Logo
                Icon(Icons.fitness_center, size: 80, color: isDark ? Colors.tealAccent : Colors.teal),
                const SizedBox(height: 20),
                Text(
                  "FitLife Pro", 
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : Colors.teal
                  )
                ),
                const SizedBox(height: 40),
                
                // 1. Email Field
                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                ),
                const SizedBox(height: 20),
                
                // 2. Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                ),
                const SizedBox(height: 20),
                
                // Error Message
                Text(error, style: const TextStyle(color: Colors.red, fontSize: 14.0)),
                const SizedBox(height: 10),
                
                // 3. Login Button
                CustomButton(
                  text: "Sign In",
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      dynamic result = await _auth.signInWithEmailPassword(
                        _emailController.text.trim(), 
                        _passwordController.text
                      );
                      if (result == null) {
                        setState(() {
                          error = 'Could not sign in with those credentials';
                          _isLoading = false;
                        });
                      }
                      // No need to set isLoading = false on success; the widget will rebuild on route change.
                    }
                  },
                ),
                const SizedBox(height: 20),
                
                // Register Link
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: Text(
                    "Don't have an account? Register", 
                    style: TextStyle(
                      color: isDark ? Colors.tealAccent : Colors.teal, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}