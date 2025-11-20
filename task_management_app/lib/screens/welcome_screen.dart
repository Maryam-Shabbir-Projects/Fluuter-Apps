import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (blue tones matching home screen)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2A3A52), Color(0xFF5B7B9B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Optional subtle overlay for more depth
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // App Name
                  Text(
                    'TaskFlow',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline or intro
                  Text(
                    'Organize your tasks\nand boost productivity',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Some subtle description
                  Text(
                    'Welcome to TaskFlow, your personal task management assistant. '
                        'Add, manage, and track your tasks seamlessly.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                  // Get Started Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff145DA0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
