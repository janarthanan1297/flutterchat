import 'package:flutter/material.dart';
import 'package:flutterchat/helper/animation.dart';
import 'package:flutterchat/data/database.dart';
import 'package:flutterchat/view/Login.dart';
import 'package:flutterchat/view/Signup.dart';

class Landing extends StatefulWidget {
  static const String routeName = 'landing';
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<Landing> {
  var email, name;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 80),
              child: Text(
                "Welcome to FlutterChat",
                style: TextStyle(
                  fontSize: 29,
                  color: Color(0xff128C7E),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                child: Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Container(
                    alignment: Alignment.topCenter,
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/whatsapp.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Read our",
                        style: TextStyle(
                          color: Color(0xff55636c),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        " Privacy Policy",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '. Tap "Agree and continue" to accept',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xff55636c),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Terms of Service.",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: size.width,
              height: 130,
              // color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(CreateRoute(page: Login()));
                      },
                      child: Container(
                        width: size.width * 0.75,
                        height: 42,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Color(0xff25D366), width: 2)),
                        child: Center(
                          child: Text(
                            "Log in",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xff25D366)),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(CreateRoute(page: SignUp()));
                      },
                      child: Container(
                        width: size.width * 0.75,
                        height: 42,
                        decoration: BoxDecoration(color: Color(0xff25D366), borderRadius: BorderRadius.circular(10), boxShadow: []),
                        child: Center(
                          child: Text(
                            "Create account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
/* 
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth!.accessToken,
      idToken: googleAuth.idToken,
    );

    // ignore: unused_local_variable
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    setState(() {
      email = FirebaseAuth.instance.currentUser!.email;
      name = FirebaseAuth.instance.currentUser!.displayName;
      debugPrint(name);
    });

    Map<String, String> userDataMap = {"userName": name, "userEmail": email};

    databaseMethods.addUserInfo(userDataMap);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatRoom()));

     HelperFunctions.saveUserLoggedInSharedPreference(true);
    HelperFunctions.saveUserNameSharedPreference(name);
    HelperFunctions.saveUserEmailSharedPreference(email.text);
  } */
}
