// ignore_for_file: file_names, avoid_print

import 'package:android/authentication/ForgotPassword.dart';
import 'package:android/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android/authentication/SignUp.dart';
import 'package:android/components/AppColors.dart';
import 'package:android/components/AppConstant.dart';
import 'package:android/components/AppWidget.dart';
import 'package:nb_utils/nb_utils.dart';

class Login extends StatefulWidget {
  static var tag = "/Login";

  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String userEmail = '';
  String userPassword = '';
  bool? hasLoggedIn;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    try {
      print("Getting ds...");
      DocumentSnapshot ds = await _firestore.collection("users").doc(userEmail).get();
      print("Got ds...");
      if (!ds.exists) {
        const snackBar = SnackBar(
          content: Text('User does not exist !'),
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isLoading = false;
        });
        return;
      } else {

          final UserCredential userCreds = await FirebaseAuth.instance.signInWithEmailAndPassword(email: userEmail, password: userPassword);
          final User? currentUser = FirebaseAuth.instance.currentUser;

          print("Adding to firestore");
          //await sendEmail();
          assert(userCreds.user!.uid == currentUser!.uid);

          if (userCreds.user != null) {
            print("User Not Null, Signing In, Redirecting To Home");
            setState(() {
              isLoading = false;
            });
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
                    (Route<dynamic> route) => false);
          } else {
            print("Auth Failed! Incorrect Password.");
            setState(() {
              isLoading = false;
            });
            const snackBar = SnackBar(
              content: Text('SignIn Failed!\nIncorrect Id or Password'),
              duration: Duration(seconds: 10),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
      }
    } catch (e) {
      print(e);
      const snackBar = SnackBar(
        content:
        Text('SignIn Failed!\nIncorrect Id or Password'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appWhite,
      // appBar: AppBar(
      //   backgroundColor: appWhite,
      //   elevation: 0.0,
      //   leading: TextButton(
      //       onPressed: (){
      //         Navigator.pop(context);
      //       },
      //       child: Container(
      //           height: deviceHeight * 0.04,
      //           width: deviceWidth * 0.08,
      //           decoration: BoxDecoration(
      //               color: appWhite,
      //               border: Border.all(color: border_colour),
      //               borderRadius: BorderRadius.all(Radius.circular(5.0))
      //           ),
      //           child: Icon(Icons.chevron_left, color: appColorPrimary)
      //       )
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.15,),
              formHeading("Welcome Back! Glad to see you, Again!",),
              SizedBox(height: deviceHeight * 0.05),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                      EditText(
                        // isPrefixIcon: true,
                        onPressed: (value) {
                          userEmail = value;
                        },
                        hintText: "Email",
                        prefixIcon: emailIcon,
                        isPassword: false,
                        isPhone: false,
                        keyboardType: TextInputType.emailAddress,
                        validatefunc: (String? value) {
                          String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regExp = RegExp(pattern);
                          if (value!.isEmpty) {
                            return 'Please enter email address';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Please enter valid email address';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: deviceHeight * 0.02),
                      EditText(
                        // isPrefixIcon: true,
                        onPressed: (value) {
                          userPassword = value;
                        },
                        hintText: "Password",
                        prefixIcon: passwordIcon,
                        isPassword: true,
                        isPhone: false,
                        validatefunc: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else if (value.length < 6) {
                            return 'Password must consist atleast 6 characters';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: deviceHeight * 0.02),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            GestureDetector(
                              onTap: () {
                                ForgotPassword().launch(context);
                              },
                              child: text("Forgot Password?", textColor: TextColorLinks, fontFamily: fontMedium),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02,),
                    isLoading
                        ?
                    const CircularProgressIndicator(color: appColorPrimary,)
                        :
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child:
                        shadowButton(
                          "Log In",
                              () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              await loginUser(context);
                            }
                          },
                        ),
                    ),
                    SizedBox(height: deviceHeight * 0.02,),
                  ],
                ),
              ),
              SizedBox(height: deviceHeight * 0.02,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  text("Don't have an account?",
                      textColor: textSecondaryColor,
                      fontSize: textSizeLargeMedium),
                  SizedBox(width: deviceWidth * 0.02),
                  GestureDetector(
                    onTap: () {
                      Signup().launch(context);
                    },
                    child: text("Register Now",
                        fontFamily: fontMedium,
                        textColor: TextColorLinks),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
