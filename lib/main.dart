import 'dart:ffi';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterphonefirebase/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        Navigator.of(context).pop();
        //UserCredential result = await _auth.signInWithCredential(credential);

        // ignore: deprecated_member_use
        FirebaseUser result =
            (await _auth.signInWithCredential(credential)).user;

        // ignore: deprecated_member_use
        //FirebaseUser user = result.user;
        if (result != null) {
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  user: result,
                ),
              ),
            );
          });
        } else {
          print("Error");
        }
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception);
      },
      codeSent: (String verificationId, [int forceResendingToken]) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Give the code?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    )
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      final code = _codeController.text.trim();
                      AuthCredential credential =
                          // ignore: deprecated_member_use
                          PhoneAuthProvider.getCredential(
                              verificationId: verificationId, smsCode: code);
                      // UserCredential result =
                      //     await _auth.signInWithCredential(credential);
                      // ignore: deprecated_member_use
                      FirebaseUser result =
                          (await _auth.signInWithCredential(credential)).user;
                      // ignore: deprecated_member_use
                      //FirebaseUser user = result.user;

                      if (result != null) {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                user: result,
                              ),
                            ),
                          );
                        });
                      } else {
                        print("Error");
                      }
                    },
                    child: Text(
                      "Confirm",
                    ),
                    textColor: Colors.white,
                    color: Colors.blue,
                  )
                ],
              );
            });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Loin",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 36,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Mobile Number",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  controller: _phoneController,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        final phone = _phoneController.text.trim();
                        loginUser(phone, context);
                      });
                    },
                    padding: EdgeInsets.all(16),
                    child: Text("Login"),
                    textColor: Colors.white,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
