import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// IMPORT CUSTOM WIDGETS
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect Dark Mode for specific UI tweaks (like the Avatar bg)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        elevation: 0,
        // FIX: Teal in Light Mode, Transparent in Dark Mode
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        // FIX: Always White text (White on Teal looks best)
        foregroundColor: Colors.white,
      ),
      // Background handled by Theme
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 1. PROFILE PICTURE SECTION ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      // If user has a photoURL, show it, else show Icon
                      backgroundImage: user?.photoURL != null 
                          ? NetworkImage(user!.photoURL!) 
                          : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor, 
                            width: 3
                          ),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. USERNAME FIELD ---
              CustomTextField(
                controller: _usernameController,
                label: "Username",
                prefixIcon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? "Please enter a username" : null,
              ),
              const SizedBox(height: 20),

              // --- 3. EMAIL FIELD ---
              CustomTextField(
                controller: _emailController,
                label: "Email Address",
                prefixIcon: Icons.email_outlined,
                validator: (val) => !val!.contains('@') ? "Invalid email" : null,
              ),
              const SizedBox(height: 20),

              // --- 4. PASSWORD FIELD ---
              CustomTextField(
                controller: _passwordController,
                label: "New Password",
                hint: "Leave blank to keep current",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (val) => (val!.isNotEmpty && val.length < 6) 
                    ? "Password must be 6+ chars" 
                    : null,
              ),
              const SizedBox(height: 40),

              // --- 5. SAVE BUTTON ---
              CustomButton(
                text: "Save Changes",
                isLoading: _isLoading,
                icon: Icons.save_alt,
                onPressed: _updateProfile,
              ),
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
        bool changed = false;

        // 1. Update Display Name
        if (_usernameController.text != user?.displayName) {
          await user?.updateDisplayName(_usernameController.text);
          changed = true;
        }

        // 2. Update Email
        if (_emailController.text != user?.email) {
          await user?.verifyBeforeUpdateEmail(_emailController.text);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification email sent to new address.")),
          );
          changed = true;
        }

        // 3. Update Password
        if (_passwordController.text.isNotEmpty) {
          await user?.updatePassword(_passwordController.text);
          changed = true;
        }

        setState(() => _isLoading = false);

        if (changed || _passwordController.text.isNotEmpty) {
           if(!mounted) return;
          _showSuccessDialog();
        } else {
           if(!mounted) return;
           Navigator.pop(context); // Nothing changed, just go back
        }

      } catch (e) {
        setState(() => _isLoading = false);
        // Handle "Requires Recent Login" error specifically if needed
        String message = "Error updating profile: ${e.toString()}";
        if (e.toString().contains('requires-recent-login')) {
          message = "For security, please log out and log in again to change sensitive info.";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- SUCCESS DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent, // Handled by container
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Adapts to Dark Mode
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 40,
                  child: Icon(Icons.check, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Profile Updated!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your changes have been saved successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close Dialog
                      Navigator.of(context).pop(); // Go back to Profile Page
                    },
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}