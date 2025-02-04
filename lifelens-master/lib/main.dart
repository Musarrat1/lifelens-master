import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


import 'package:lifelens/screens/dashboard.dart';

import 'package:lifelens/screens/sign_in.dart';
import 'package:lifelens/screens/sign_up.dart';

import 'package:lifelens/screens/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



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
        SignInScreen.routeName: (context) => SignInScreen(),
        SignUpScreen.routeName: (context) =>  SignUpScreen(),

        Dashboard.routeName: (context) => const Dashboard(),

      },
    );
  }
}