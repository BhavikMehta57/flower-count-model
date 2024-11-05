// ignore_for_file: file_names, avoid_print

import 'package:android/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android/authentication/Login.dart';
import 'package:android/components/AppColors.dart';
import 'package:android/components/AppConstant.dart';
import 'package:android/components/AppWidget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? fullName;
  String? companyName;
  String userEmail = '';
  String password = '';
  String? rePassword;
  bool isLoading = false;
  bool agree = true;

  startLoading() => setState(() {
    isLoading = true;
  });
  stopLoading() => setState(() {
    isLoading = false;
  });

  @override
  void initState() {
    super.initState();
  }

  Future<void> addAdminToDatabase() async {
    await _firestore.collection("users").doc(userEmail).set({
      "Username": fullName,
      "Email": userEmail,
      "Registered On": DateTime.now().toString(),
      "isVerified": true,
      "isBlocked": false,
    });
    await FirebaseAuth.instance.currentUser!.updateDisplayName(fullName);
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(DefaultProfilPhotoURL);
  }

  // Future<void> sendEmail() async {
  //   String phone = '${countryCode!}${phoneNumber!}';
  //   try {
  //     String username = "androidbrainvita@gmail.com";//"brainvita5@gmail.com";
  //     String password = "dzzbglaumubloils";//"fouctsjoilonnqfh";
  //     final smtpServer = gmail(username,password);
  //     final message = Message()
  //       ..from = Address(username)
  //       ..recipients.add('androidbrainvita@gmail.com')
  //       ..subject = 'New User Signup for $phone' //subject of the email
  //       ..text = "Name: $fullName\nFather's Name: $fatherName\nMother's Name: $motherName\n"
  //           "Education: $education\nEmailID: $email\nPhone Number: $phone\n"
  //           "Date of Birth: $dateOfBirth\nTime of Birth: ${timeOfBirth.hour}:${timeOfBirth.minute}\nPlace of Birth: $placeOfBirth\n"
  //           "Franchise: $franchise";
  //     try {
  //       var connection = PersistentConnection(smtpServer);
  //       await connection.send(message).timeout(const Duration(seconds: 300));
  //       await connection.close();
  //       print('Message sent: ');
  //     } on MailerException catch (e) {
  //       print('Message not sent. \n'+ e.toString()); //print if the email is not sent
  //       // e.toString() will show why the email is not sending
  //       const snackBar = SnackBar(
  //         content: Text('SignUp Failed\nPlease Check your internet connection and try again'),
  //         duration: Duration(seconds: 10),
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     }
  //   } catch(e){
  //     print(e.toString());
  //     const snackBar = SnackBar(
  //       content: Text('SignUp Failed!\nPlease Check your internet connection and try again'),
  //       duration: Duration(seconds: 10),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  Future<void> processRegisterRequest(context) async {
    try {
      final UserCredential userCreds = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: userEmail, password: password);
      final User? currentUser = FirebaseAuth.instance.currentUser;

      print("Adding to firestore");
      // Store user details in database
      await addAdminToDatabase();
      //await sendEmail();
      assert(userCreds.user!.uid == currentUser!.uid);

      if (userCreds.user != null) {
        print("User Not Null, Signing In, Redirecting To Home");
        stopLoading();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
                (Route<dynamic> route) => false);
      } else {
        print("Auth Failed! (Login, from verify callback)");
        stopLoading();
        const snackBar = SnackBar(
          content: Text('SignUp Failed!\nPlease Check your internet connection and try again'),
          duration: Duration(seconds: 10),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e.toString());
      stopLoading();
      const snackBar = SnackBar(
        content: Text('SignUp Failed!\nPlease Check your internet connection and try again'),
        duration: Duration(seconds: 10),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: appWhite,
        appBar: AppBar(
          backgroundColor: appWhite,
          elevation: 0.0,
          leading: TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Container(
                  height: deviceHeight * 0.04,
                  width: deviceWidth * 0.08,
                  decoration: BoxDecoration(
                      color: appWhite,
                      border: Border.all(color: border_colour),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  child: Icon(Icons.chevron_left, color: appColorPrimary)
              )
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: deviceHeight * 0.05,),
                formHeading("Hello! Register to get started",),
                SizedBox(height: deviceHeight * 0.05),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                        EditText(
                          // isPrefixIcon: true,
                          //full name
                          onPressed: (value) {
                            fullName = value;
                          },
                          hintText: "Full Name",
                          prefixIcon: fullnameIcon,
                          isPassword: false,
                          isPhone: false,
                          validatefunc: (String? value) {
                            if (value!.isEmpty) {
                              return "Please enter your full name";
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: deviceHeight * 0.02),

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
                            password = value;
                            print(password);
                          },
                          hintText: "Password",
                          prefixIcon: passwordIcon,
                          isPassword: true,
                          isPhone: false,
                          validatefunc: (String? value) {
                            if (value!.isEmpty) {
                              return "Please enter a password";
                            } else if (value.length < 6) {
                              return "Password must consist atleast 6 characters";
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: deviceHeight * 0.02),
                        EditText(
                          // isPrefixIcon: true,
                          onPressed: (value) {
                            rePassword = value;

                            print(rePassword);
                          },
                          hintText: "Re-enter Password",
                          prefixIcon: passwordIcon,
                          isPassword: true,
                          isPhone: false,
                          validatefunc: (String? value) {
                            if (value!.isEmpty) {
                              return "Please re-enter your password";
                            } else if (value.length < 6) {
                              return "Password must consist atleast 6 characters";
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: deviceHeight * 0.02),

                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                side: BorderSide(color: appColorPrimary),
                                activeColor: TextColorPrimary,
                                value: agree,
                                onChanged: (value) {
                                  setState(() {
                                    agree = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                      text: "By Signing Up, You agree with the \n",
                                      style: TextStyle(
                                          color: TextColorPrimary
                                      ),
                                      children:[
                                        TextSpan(
                                          text: "Terms of Use",
                                          style: TextStyle(
                                              color: TextColorLinks,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = () {
                                            // Navigator.of(context).push(
                                            //     MaterialPageRoute(
                                            //       builder: (context) => TermsOfUse(),
                                            //     )
                                            // );
                                          },
                                        ),
                                        TextSpan(
                                          text: " & ",
                                          style: TextStyle(
                                              color: TextColorPrimary
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: TextStyle(
                                              color: TextColorLinks,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = () {
                                            print("Tap");
                                            launchUrl(Uri.parse("https://github.com/BhavikMehta57/esanskarancardprivacypolicy"));
                                          },
                                        ),
                                      ]
                                  ),
                                  maxLines: 3,
                                ),
                              )
                            ],
                          ),
                        ),
                      SizedBox(height: deviceHeight * 0.02),
                      isLoading
                          ?
                      const CircularProgressIndicator(color: appColorPrimary,)
                          :
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child:
                          shadowButton(
                              "Register",
                                  () async {
                                if (_formKey.currentState!.validate() && agree) {
                                  startLoading();
                                  if (rePassword == password) {
                                    try {
                                      DocumentSnapshot ds = await _firestore
                                          .collection("users")
                                          .doc(userEmail)
                                          .get();

                                      if (ds.exists) {
                                        const snackBar = SnackBar(
                                          content: Text('Account with this email already exists !'),
                                          duration:
                                          Duration(seconds: 5),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        stopLoading();
                                        return;
                                      } else {
                                        // Process registration
                                        await processRegisterRequest(context);
                                      }
                                    } catch (e) {
                                      print(e);
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'SignUp Failed. Please try again'),
                                        duration: Duration(seconds: 3),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      stopLoading();
                                      return;
                                    }
                                  } else {
                                    const snackBar = SnackBar(
                                      content: Text(
                                          'Passwords do not match'),
                                      duration: Duration(seconds: 3),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    stopLoading();
                                    return;
                                  }
                                } else {
                                  if (!agree) {
                                    const snackBar = SnackBar(
                                      content: Text(
                                          'You need to agree to the terms and conditions and privacy policy'),
                                      duration: Duration(seconds: 3),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              },
                          ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: deviceHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      text("Already have an account?",
                          textColor: textSecondaryColor,
                          fontSize: textSizeLargeMedium),
                      SizedBox(width: deviceWidth * 0.02),
                      GestureDetector(
                        onTap: () {
                          Login().launch(context);
                        },
                        child: text("Login Now",
                            fontFamily: fontMedium,
                            textColor: TextColorLinks),
                      )
                    ],
                  ),
                SizedBox(height: deviceHeight * 0.02),
              ],
            ),
          ),
        )
    );
  }
}
