// ignore_for_file: file_names, avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:android/authentication/Login.dart';
import 'package:android/components/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android/components/AppConstant.dart';
import 'package:android/components/AppWidget.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController email = TextEditingController();
  bool isLoading=false;

  startLoading()=>setState((){isLoading=true;});
  stopLoading()=>setState((){isLoading=false;});

  showSuccessDialog(String title, String message){
    AwesomeDialog(
        dismissOnTouchOutside:false,
        context: _scaffoldKey.currentContext!,
        animType: AnimType.leftSlide,
        headerAnimationLoop: false,
        dialogType: DialogType.success,
        title: title,
        desc: message,
        btnOkOnPress: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
                  (Route<dynamic> route) => false
          );
        },
        btnOkIcon: Icons.check_circle,
        btnCancelIcon: Icons.cancel,
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback');
        }).show();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key:_scaffoldKey,
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
              children: <Widget>[
                // FadeAnimation(
                //     0.4,
                //     commonCacheImageWidget(SignLogo, 100,
                //         width: 100, fit: BoxFit.fill)),
                SizedBox(height: deviceHeight * 0.05),
                formHeading("Forgot Password"),
                SizedBox(height: deviceHeight * 0.05),

                  text(
                    "Enter Registered Email ID.\nWe'll send password reset instructions.",
                    textColor: TextColorSecondary,
                    fontSize: textSizeLargeMedium,
                    isLongText: true,
                    isCentered: true,
                  ),
                SizedBox(height: deviceHeight * 0.05),
                Form(
                  key: _formKey,
                  child: EditText(
                      // isPrefixIcon: true,
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      onPressed: (value) {
                        // email.text = value;
                        print(email.text);
                      },
                      hintText: "Email",
                      prefixIcon: emailIcon,
                      isPassword: false,
                      isPhone: true,
                      validatefunc: (String? value) {
                        String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regExp = RegExp(pattern);
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
                        }
                        else if (!regExp.hasMatch(value)) {
                          return 'Please enter valid email id';
                        }
                        return null;
                      },
                    ),
                  ),
                SizedBox(height: deviceHeight * 0.02),
                isLoading?
                const CircularProgressIndicator(color: appColorPrimary,)
                    :
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: shadowButton("Send", () async{
                      startLoading();
                      if(_formKey.currentState!.validate())
                      {
                        String emailiD = email.text;
                        try{
                          DocumentSnapshot ds = await _firestore.collection("admins").doc(emailiD).get();
                          if(! ds.exists){
                            const snackBar = SnackBar(
                              content: Text('User does not exist!'),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            stopLoading();
                            return;
                          }
                          else{
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: emailiD).then((value) {
                              showSuccessDialog("Success", "Password Reset Link Sent. Please login with new credentials after resetting password.");
                            });
                            stopLoading();
                            return;
                          }
                        } catch(e) {
                          print(e);
                          const snackBar = SnackBar(
                            content: Text('Some error occurred! Please check you internet connection.'),
                            duration: Duration(seconds: 3),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() {
                            isLoading=false;
                          });
                          return;
                        }
                      } else {
                        stopLoading();
                      }
                    }),
                  ),
                SizedBox(height: deviceHeight * 0.02),
              ],
            ),
          ),
      ),
    );
  }
}