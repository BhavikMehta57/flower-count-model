import 'dart:convert';
import 'dart:io';

import 'package:android/components/AppColors.dart';
import 'package:android/components/SplashScreen.dart';
import 'package:android/screens/CameraScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Assignment App',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFFf2866c, <int, Color>{
          50: Color(0xFFf2866c),
          100: Color(0xFFf2866c),
          200: Color(0xFFf2866c),
          300: Color(0xFFf2866c),
          400: Color(0xFFf2866c),
          500: Color(0xFFf2866c),
          600: Color(0xFFf2866c),
          700: Color(0xFFf2866c),
          800: Color(0xFFf2866c),
          900: Color(0xFFf2866c),
        },
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SDSplashScreen(),
    );
  }
}