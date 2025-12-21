import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                const Text("FitLife Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) => setState(() => email = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                  onChanged: (val) => setState(() => password = val),
                ),
                const SizedBox(height: 20),
                Text(error, style: const TextStyle(color: Colors.red, fontSize: 14.0)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        dynamic result = await _auth.signInWithEmailPassword(email, password);
                        if (result == null) {
                          setState(() => error = 'Could not sign in with those credentials');
                        }
                      }
                    },
                    child: const Text("Sign In", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text("Register", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}