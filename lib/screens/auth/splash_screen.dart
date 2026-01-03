import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Multiple animations for a "Staggered" effect
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 Seconds total
    );

    // 2. Define Staggered Animations
    
    // Logo appears first (0% to 50% of timeline)
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Text slides up later (40% to 100% of timeline)
    _textSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    // 3. Start Animation and Navigation Logic
    _controller.forward();
    _handleNavigation();
  }

  // Smart Navigation: Checks Authentication while animating
  Future<void> _handleNavigation() async {
    // Ensure the splash stays for at least 2.5 seconds so user sees the animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check if user is already logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Premium Linear Gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D40), // Deep Teal
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- BACKGROUND PATTERN (Optional Subtle Circles) ---
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // --- MAIN CONTENT ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. ANIMATED LOGO WITH GLOW
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade700, 
                        shape: BoxShape.circle,
                        boxShadow: [
                          // Glow Effect
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // 2. SLIDING TEXT
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          "FitLife Pro",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900, // Very Bold
                            color: Colors.white,
                            letterSpacing: 2.0, // Premium spacing
                            fontFamily: 'Roboto', // Or your custom font
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "ELEVATE YOUR FITNESS", // All Caps tagline looks pro
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.tealAccent.shade400, // Accent color
                            letterSpacing: 4.0, // Wide spacing for tagline
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- BOTTOM LOADER ---
            Positioned(
              bottom: 50,
              child: FadeTransition(
                opacity: _textFadeAnimation, // Fade in with text
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white38,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}