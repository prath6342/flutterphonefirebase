import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String phoneNo;
  String smsCode;
  String verificationId;

  Future<Void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrive = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (PhoneAuthCredential user) {
      print('Verify');
    };

    final PhoneVerificationFailed verifiFailed =
        (FirebaseAuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        verificationCompleted: verifiedSuccess,
        verificationFailed: verifiFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrive,
        timeout: const Duration(seconds: 5));
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter SMS Code',
          ),
          content: TextField(
            onChanged: (value) {
              this.smsCode = value;
            },
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                FirebaseAuth.instance.currentUser().then((user) {
                  if (user != null) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/homepage');
                  } else {
                    Navigator.of(context).pop();
                  }
                });
              },
              child: Text('Done'),
            )
          ],
        );
      },
    );
  }

  signIn() {
    // ignore: deprecated_member_use
    PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
    // FirebaseAuth.instance
    //     .Pho(phoneNo, verificationId)
    //     .then((value) {})
    //     .catchError((e) {
    //   print(e);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Auth'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter Mobile Number'),
                onChanged: (value) {
                  this.phoneNo = value;
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                onPressed: verifyPhone,
                child: Text('Verify'),
                textColor: Colors.white,
                elevation: 7.0,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
