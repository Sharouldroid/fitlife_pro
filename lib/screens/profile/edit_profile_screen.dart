import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing data
    if (user != null) {
      _usernameController.text = user!.displayName ?? '';
      _emailController.text = user!.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView( // Added scroll view for smaller screens
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. USERNAME FIELD
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Please enter a username" : null,
              ),
              const SizedBox(height: 15),

              // 2. EMAIL FIELD
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => !val!.contains('@') ? "Invalid email" : null,
              ),
              const SizedBox(height: 15),

              // 3. PASSWORD FIELD
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  helperText: "Leave blank to keep current password",
                ),
                // Password is optional validation
                validator: (val) => (val!.isNotEmpty && val.length < 6) 
                    ? "Password must be 6+ chars" 
                    : null,
              ),
              const SizedBox(height: 30),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UPDATE LOGIC ---
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 1. Update Display Name (Username)
        if (_usernameController.text != user?.displayName) {
          await user?.updateDisplayName(_usernameController.text);
        }

        // 2. Update Email (if changed)
        if (_emailController.text != user?.email) {
          await user?.verifyBeforeUpdateEmail(_emailController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification email sent to new address.")),
          );
        }

        // 3. Update Password (if provided)
        if (_passwordController.text.isNotEmpty) {
          await user?.updatePassword(_passwordController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!")),
        );
        
        Navigator.pop(context); // Go back to Profile Page

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}