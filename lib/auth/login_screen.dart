import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_interface/auth/signup_screen.dart';
import 'package:users_interface/meth/common_meth.dart';

import '../pages/homepage.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMeth cMeth = CommonMeth();
  String userName = ""; // Define the userName variable

  // Check if the network is available and validate the form
  void checkIfNetworkIsAvailable() {
    cMeth.checkConnectivity(context);
    signInFormValidation();
  }

  // Validate the sign-in form
  void signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      cMeth.displaysSnackBar("Your email is not valid", context);
    } else if (passwordTextEditingController.text.trim().length < 7) {
      cMeth.displaysSnackBar("Your password must be at least 8 or more characters", context);
    } else {
      signInUser();
    }
  }

  // Sign in the user with Firebase Authentication
  Future<void> signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => loadDialogue(messageText: "Logging you in..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg) {
          cMeth.displaysSnackBar(errorMsg.toString(), context);
        })
    ).user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      userRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c) => Homepage()));
          } else {
            FirebaseAuth.instance.signOut();
            cMeth.displaysSnackBar("You have been blocked. Please contact the admin for further questions.", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMeth.displaysSnackBar("You haven't signed up as a user.", context);
        }
      });
    }
  }

  // Loading dialog widget
  Widget loadDialogue({required String messageText}) {
    return AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 10),
          Text(messageText),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    children: [
                      Image.asset("assets/images/logo.png"),
                      const Text(
                        "Login as a User",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Text fields and button
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailTextEditingController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(fontSize: 14),
                              ),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 22),

                            TextField(
                              controller: passwordTextEditingController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(fontSize: 14),
                              ),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 32),

                            ElevatedButton(
                              onPressed: () async {
                                signInFormValidation();
                                //checkIfNetworkIsAvailable();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20)),
                              child: const Text("Login"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Text button
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => signUpScreen()));
                        },
                        child: const Text(
                          "Don't have an account yet? Sign Up Here!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ]
                )
            )
        )
    );
  }
}