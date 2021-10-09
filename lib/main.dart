// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterchat/view/Landing.dart';
import 'package:flutterchat/view/chatroom.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

User? user = FirebaseAuth.instance.currentUser;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlutterChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xff075E54),
          scaffoldBackgroundColor: Color(0xFFFFFFFF),
          fontFamily: "Helvetica",
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff25D366)),
        ),
        home: (user == null) ? Landing() : ChatRoom());
  }
}
