import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash'; // Static route name for navigation

  @override
  Widget build(BuildContext context) {
    // To prevent multiple navigation calls
    bool _hasNavigated = false;

    // Delayed navigation to Login Screen
    Future.delayed(const Duration(seconds: 3), () {
      if (!_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration image
            Container(
              height: 200,
              width: 200,
              child: Image.asset(
                'assets/splash_screen_image.png', // Update asset path
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Subtitle with RichText
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Stay organized, ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'stay inspired—your daily life, streamlined.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Get Started Button
            ElevatedButton(
              onPressed: () {
                if (!_hasNavigated) {
                  _hasNavigated = true;
                  Navigator.pushReplacementNamed(context, '/login'); // Navigate to Login Screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
