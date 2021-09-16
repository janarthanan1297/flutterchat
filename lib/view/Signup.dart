import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/data/helperfunctions.dart';
import 'package:flutterchat/helper/animation.dart';
import 'package:flutterchat/view/chatroom.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutterchat/data/database.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  int words = 0;
  var age;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  void signup() async {
    CircularProgressIndicator();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      User? user = userCredential.user;
      //FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ignore: deprecated_member_use
        user.updateProfile(displayName: name.text.trim());
        Map<String, String> userDataMap = {"userName": name.text, "userEmail": email.text};

        databaseMethods.addUserInfo(userDataMap);

        HelperFunctions.saveUserLoggedInSharedPreference(true);
        HelperFunctions.saveUserNameSharedPreference(name.text);
        HelperFunctions.saveUserEmailSharedPreference(email.text);

        Navigator.of(context).pushReplacement(CreateRoute(page: ChatRoom()));
      }
    } catch (err) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
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
                            signup();
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
                                  "Next",
                                  style: TextStyle(
                                    fontFamily: "IBM",
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
                  padding: EdgeInsets.only(top: 20, left: 40),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create your\naccount",
                    style: TextStyle(
                      fontFamily: 'IBM',
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            words = 50 - value.length;
                          });
                        },
                        autofocus: false,
                        focusNode: _focusNode1,
                        controller: name,
                        onEditingComplete: (() {
                          FocusScope.of(context).nextFocus();
                        }),
                        decoration: InputDecoration(
                          hintText: "Name",
                          hintStyle: TextStyle(
                            fontFamily: "IBM",
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff55636c),
                          ),
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: (words >= 0) ? Color(0xff25D366) : Colors.red, width: 2),
                          ),
                          enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Name';
                          } else if (words < 0) {
                            return 'You crossed the maximum limit';
                          }
                          return null;
                        },
                      ),
                      new Align(
                          alignment: FractionalOffset.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Container(
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              width: 70,
                              height: 40,
                              child: Text(
                                (name.text.length == 0) ? '50' : '$words',
                                style: TextStyle(
                                  fontFamily: "IBM",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff55636c),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          )),
                      TextFormField(
                        focusNode: _focusNode2,
                        controller: email,
                        onEditingComplete: (() => FocusScope.of(context).nextFocus()),
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
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            words = 50 - value.length;
                          });
                        },
                        autofocus: false,
                        focusNode: _focusNode3,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
