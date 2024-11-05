// ignore_for_file: file_names

import 'dart:async';

import 'package:android/authentication/Login.dart';
import 'package:android/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SDSplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SDSplashScreenState createState() => _SDSplashScreenState();
}

class _SDSplashScreenState extends State<SDSplashScreen>
    with SingleTickerProviderStateMixin {
  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, navigate);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigate() async {
    /// if logged in redirect to home screen
    if (FirebaseAuth.instance.currentUser != null) {
      print("Splash screen, user found!");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
              (Route<dynamic> route) => false);
    }
    /// else redirect to Login screen
    else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
              (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Container(
            //   margin: const EdgeInsets.only(top: 16),
            //   child: Image.asset("assets/images/logo.jpeg", height: 150.0),
            // ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Text(
                'Camera Assignment App',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w500,
                    fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
