import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {

    bool _hasNavigated = false;


    Future.delayed(const Duration(seconds: 3), () {
      if (!_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(context, '/signinscreen');
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

            ElevatedButton(
              onPressed: () {
                if (!_hasNavigated) {
                  _hasNavigated = true;
                  Navigator.pushReplacementNamed(context, '/signinscreen');
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
