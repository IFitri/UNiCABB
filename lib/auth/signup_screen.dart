import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_interface/auth/login_screen.dart';
import 'package:users_interface/meth/common_meth.dart';
import 'package:users_interface/pages/homepage.dart';
import 'package:users_interface/widgets/load_dialogue.dart';

class signUpScreen extends StatefulWidget {
  signUpScreen({super.key});

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMeth cMeth = CommonMeth();

  checkIfNetworkIsAvailable()
  {
    cMeth.checkConnectivity(context);
    signupFormValidation();
  }

  signupFormValidation()
  {
    if(userNameTextEditingController.text.trim().length < 7)
    {
      cMeth.displaysSnackBar("Your username must be at least 8 or more characters", context);
    }
    else if(userPhoneTextEditingController.text.trim().length < 10)
    {
    cMeth.displaysSnackBar("Your phone number is not valid", context);
    }
    else if(!emailTextEditingController.text.contains("@"))
    {
    cMeth.displaysSnackBar("Your email is not valid", context);
    }
    else if(passwordTextEditingController.text.trim().length < 7)
    {
    cMeth.displaysSnackBar("Your password must be at least 8 or more characters", context);
    }
    else
      {
        registerNewUser();
      }
  }

  registerNewUser() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => loadDialogue(messageText: "Registering your account..."),
        );

    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ).catchError((errorMsg)
        {
          cMeth.displaysSnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);

    Map userDataMap =
      {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": "yes",
      };
      userRef.set(userDataMap);

    showAlertDialog(context);
      //Navigator.push(context, MaterialPageRoute(builder: (c) => Homepage()));
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registration Successful"),
          content: Text("Your account has been registered successfully!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
            children: [

              Image.asset(
                "assets/images/logo.png"
              ),

              const Text(
                "Create a User's Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                )
              ),

              //text fields + button
              Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [

                      TextField(
                        controller: userNameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22,),

                      TextField(
                        controller: userPhoneTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22,),

                      TextField(
                          controller: emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "School E-mail",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                      const SizedBox(height: 22,),

                      TextField(
                          controller: passwordTextEditingController,
                          obscureText: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Password'",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                      const SizedBox(height: 32,),

                      ElevatedButton(
                        onPressed: ()
                        {
                          signupFormValidation();
                          //checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20)
                        ),
                        child: const Text(
                          "Sign up"
                        ),
                      ),

                    ],
                  ),
              ),

              const SizedBox(height: 12,),

              //textButton
              TextButton(
                  onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> loginScreen()));
                  },
                  child: const Text(
                    "Already have an Account? Login Here",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
              ),

            ]
        )
        )
      )
    );
  }
}
