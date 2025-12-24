import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
// IMPORT CUSTOM WIDGETS
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Use Controllers
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        elevation: 0,
        // Background color handled by Theme
      ),
      // Background color handled by Theme
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Email Field (With Regex)
              CustomTextField(
                controller: _emailController,
                label: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter an email';
                  }
                  // Slightly improved regex for broader support
                  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val);
                  if (!emailValid) {
                    return 'Enter a valid email (e.g. name@mail.com)';
                  }
                  return null;
                },
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
              Text(
                error, 
                style: const TextStyle(color: Colors.red, fontSize: 14.0)
              ),
              const SizedBox(height: 10),
              
              // 3. Register Button
              CustomButton(
                text: "Register",
                isLoading: _isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    
                    dynamic result = await _auth.registerWithEmailPassword(
                      _emailController.text.trim(), 
                      _passwordController.text
                    );
                    
                    if (result == null) {
                      if (mounted) {
                        setState(() {
                          error = 'Registration failed. Email might be in use.';
                          _isLoading = false;
                        });
                      }
                    } else {
                      if (mounted) {
                        Navigator.pop(context); // Go back to Login on success
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}