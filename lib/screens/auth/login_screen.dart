import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. ADD THIS IMPORT
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final AuthService _auth = AuthService(); // Not needed for direct call, but okay to keep
  final _formKey = GlobalKey<FormState>();

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                
                Text(error, style: const TextStyle(color: Colors.red, fontSize: 14.0)),
                const SizedBox(height: 10),
                
                // 3. Login Button (UPDATED LOGIC)
                CustomButton(
                  text: "Sign In",
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      
                      // --- THIS IS THE LOGIC YOU ASKED FOR ---
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        // FORCE NAVIGATION ON SUCCESS
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                        
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          error = e.message ?? 'Could not sign in with those credentials';
                          _isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          error = 'An unexpected error occurred';
                          _isLoading = false;
                        });
                      }
                      // ---------------------------------------
                    }
                  },
                ),
                const SizedBox(height: 20),
                
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