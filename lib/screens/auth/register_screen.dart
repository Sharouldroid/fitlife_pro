import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account"), backgroundColor: Colors.teal),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ==============================
              // IMPROVED EMAIL LOGIC HERE
              // ==============================
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Email", 
                  prefixIcon: Icon(Icons.email), 
                  border: OutlineInputBorder()
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter an email';
                  }
                  // Logic: Check for valid email pattern using Regex
                  // This checks for [text] + [@] + [text] + [.] + [text]
                  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val);
                  
                  if (!emailValid) {
                    return 'Enter a valid email (e.g. name@mail.com)';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(height: 20),
              
              // PASSWORD INPUT
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Password", 
                  prefixIcon: Icon(Icons.lock), 
                  border: OutlineInputBorder()
                ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                onChanged: (val) => setState(() => password = val),
              ),
              const SizedBox(height: 20),
              
              // ERROR MESSAGE
              Text(
                error, 
                style: const TextStyle(color: Colors.red, fontSize: 14.0)
              ),
              const SizedBox(height: 10),
              
              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () async {
                    // 1. Run the validators (Email & Password check)
                    if (_formKey.currentState!.validate()) {
                      setState(() => loading = true);
                      
                      // 2. Attempt Registration
                      dynamic result = await _auth.registerWithEmailPassword(email, password);
                      
                      if (result == null) {
                        // 3. Handle Failure
                        setState(() {
                          error = 'Registration failed. Email might be in use.';
                          loading = false;
                        });
                      } else {
                        // 4. Handle Success (Close screen or Navigate)
                        if (mounted) {
                           Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: loading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}