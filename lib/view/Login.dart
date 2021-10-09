import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/data/database.dart';
import 'package:flutterchat/data/helperfunctions.dart';
import 'package:flutterchat/helper/animation.dart';
import 'package:flutterchat/view/chatroom.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  final name, email, dob;
  const Login({Key? key, this.name, this.email, this.dob}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool submitValid = false;
  int words = 0;
  bool _obscureText = true;
  bool isLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

  void logInToEmail() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: password.text.trim()).then((result) async {
        // ignore: unnecessary_null_comparison
        if (result != null) {
          QuerySnapshot userInfoSnapshot = await DatabaseMethods().getUserInfo(email.text.trim());

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(userInfoSnapshot.docs[0]["userName"]);
          HelperFunctions.saveUserEmailSharedPreference(userInfoSnapshot.docs[0]["userEmail"]);

          Navigator.of(context).pushReplacement(CreateRoute(page: ChatRoom()));
        } else {
          setState(() {
            isLoading = false;
            //show snackbar
          });
        }
        // ignore: null_argument_to_non_null_type
        return Future.value();
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.toString()),
              actions: [
                ElevatedButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } //finally {
    //isLoading = false;
    //}
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            //padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Visibility(
                        child: Padding(
                            padding: EdgeInsets.only(top: 34, left: 0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 25,
                                  color: Color(0xff128C7E),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            )),
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 37),
                          child: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Color(0xff25D366),
                            size: 35,
                          ),
                        )),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            logInToEmail();
                          }
                        },
                        child: new Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0, top: 35),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 70,
                                height: 40,
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff128C7E),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )),
                      ),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 35, left: 40),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "To get started, first enter your email & password.",
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    autofocus: false,
                    focusNode: _focusNode1,
                    controller: email,
                    onEditingComplete: (() {
                      FocusScope.of(context).nextFocus();
                    }),
                    decoration: InputDecoration(
                      hintText: "Email address",
                      hintStyle: TextStyle(
                        fontFamily: "IBM",
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff55636c),
                      ),
                      focusedBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Color(0xff25D366), width: 2),
                      ),
                      enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Email Address';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email address!';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: false,
                        focusNode: _focusNode2,
                        controller: password,
                        obscureText: _obscureText,
                        onEditingComplete: (() {
                          FocusScope.of(context).nextFocus();
                        }),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            fontFamily: "IBM",
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff55636c),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                            color: Color(0xff25D366),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Color(0xff25D366), width: 2),
                          ),
                          enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters!';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                    child: TextButton(
                  child: Text(
                    "Forgot Password ?",
                    style: TextStyle(
                      color: Color(0xff25D366),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(CreateRoute(page: ForgotPassword()));
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPassword extends StatefulWidget {
  final name, email, dob;
  const ForgotPassword({Key? key, this.name, this.email, this.dob}) : super(key: key);
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with SingleTickerProviderStateMixin {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int words = 0;
  TextEditingController forgotPassword = TextEditingController();

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            //padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Visibility(
                        child: Padding(
                            padding: EdgeInsets.only(top: 34, left: 0),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 25,
                                  color: Color(0xff128C7E),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            )),
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 37),
                          child: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Color(0xff25D366),
                            size: 35,
                          ),
                        )),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            /*   Navigator.push(context,
                                new MaterialPageRoute(builder: (context) => Privacy1(email: email.text, name: name.text, dob: dob.text, age: age))); */
                          }
                        },
                        child: new Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0, top: 35),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 70,
                                height: 40,
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff128C7E),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )),
                      ),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 25, left: 40),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reset your Twitter account",
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    autofocus: false,
                    focusNode: _focusNode1,
                    controller: forgotPassword,
                    onEditingComplete: (() {
                      FocusScope.of(context).nextFocus();
                    }),
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: TextStyle(
                        fontFamily: "IBM",
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff55636c),
                      ),
                      focusedBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Color(0xff25D366), width: 2),
                      ),
                      enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Email Address';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email address!';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
