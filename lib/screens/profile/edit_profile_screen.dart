import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:image_picker/image_picker.dart'; 
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

  // We grab the user here, but we will refresh it later
  User? user = FirebaseAuth.instance.currentUser;
  
  bool _isLoading = false;
  File? _imageFile; 

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _usernameController.text = user!.displayName ?? '';
      _emailController.text = user!.email ?? '';
    }
  }

  // --- 1. FUNCTION TO PICK IMAGE ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 2. PROFILE PICTURE WITH TAP ACTION ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage, 
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        // Show Local File if picked, else show Network URL, else Icon
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null),
                        child: (_imageFile == null && user?.photoURL == null)
                            ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor, 
                              width: 3
                            ),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- INPUT FIELDS ---
              CustomTextField(
                controller: _usernameController,
                label: "Username",
                prefixIcon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? "Please enter a username" : null,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _emailController,
                label: "Email Address",
                prefixIcon: Icons.email_outlined,
                validator: (val) => !val!.contains('@') ? "Invalid email" : null,
              ),
              const SizedBox(height: 20),

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

  // --- 3. UPDATE LOGIC ---
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        bool changed = false;

        // A. UPLOAD IMAGE IF SELECTED
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_profiles')
              .child('${user!.uid}.jpg');

          // Upload
          await storageRef.putFile(_imageFile!);
          
          // Get URL
          final String downloadUrl = await storageRef.getDownloadURL();

          // Update Profile
          await user?.updatePhotoURL(downloadUrl);
          changed = true;
        }

        // B. Update Display Name
        if (_usernameController.text != user?.displayName) {
          await user?.updateDisplayName(_usernameController.text);
          changed = true;
        }

        // C. Update Email
        if (_emailController.text != user?.email) {
          await user?.verifyBeforeUpdateEmail(_emailController.text);
          changed = true;
        }

        // D. Update Password
        if (_passwordController.text.isNotEmpty) {
          await user?.updatePassword(_passwordController.text);
          changed = true;
        }

        // --- CRITICAL FIX: FORCE RELOAD ---
        // This forces the local Firebase User object to sync with the server immediately.
        // Without this, the Dashboard might still show the old photo for a few seconds.
        await user?.reload();
        user = FirebaseAuth.instance.currentUser; // Refresh local reference

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (changed || _passwordController.text.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
           );
           Navigator.pop(context); 
        } else {
           Navigator.pop(context);
        }

      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }
}