import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lifelens/screens/dashboard.dart';
import 'package:lifelens/screens/login_screen.dart';
import 'package:lifelens/screens/sign_in.dart';
import 'package:lifelens/screens/sign_up.dart';
import 'package:lifelens/screens/otp_screen.dart';
import 'package:lifelens/screens/signup_screen.dart';
import 'package:lifelens/screens/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('myBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        Login.routeName: (context) => SignInScreen(),
        SignUp.routeName: (context) => const  SignUpScreen(),
        OTP.routeName: (context) => const OTP( verificationID: '',),
        Dashboard.routeName: (context) => const Dashboard(),

      },
    );
  }
}