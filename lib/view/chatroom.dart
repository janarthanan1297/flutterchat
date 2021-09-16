import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutterchat/data/database.dart';
import 'package:flutterchat/data/helperfunctions.dart';
import 'package:flutterchat/helper/animation.dart';
import 'package:flutterchat/view/Landing.dart';
import 'package:flutterchat/view/chat.dart';
import 'package:flutterchat/view/search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream? chatRooms;
  bool isLoading = true;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                Container(
                  child: FaIcon(
                    FontAwesomeIcons.solidComments,
                    color: Colors.green.shade100,
                    size: 150,
                  ),
                ),
                Text(
                  'No Chats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        }
        var length = snapshot.data.docs.length;
        if (length == 0) {
          return Container(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                Container(
                  child: FaIcon(
                    FontAwesomeIcons.solidComments,
                    color: Colors.green.shade100,
                    size: 150,
                  ),
                ),
                Text(
                  'No Chats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        }
        return AnimationLimiter(
          child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 850),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        padding: EdgeInsets.all(3),
                        child: ChatRoomsTile(
                          userName: snapshot.data.docs[index]['chatRoomId'].toString().replaceAll("_", "").replaceAll(Constants.myName, ""),
                          chatRoomId: snapshot.data.docs[index]["chatRoomId"],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
    // ignore: unused_local_variable
    Timer _everySecond = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        isLoading = false;
      });
    });
  }

  getUserInfogetChats() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        debugPrint("we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "FlutterChat",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21, color: Colors.white),
        ),
        elevation: 3.0,
        centerTitle: false,
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(CreateRoute(page: Search()));
              }),
          PopupMenuButton<String>(
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (BuildContext contesxt) {
              return [
                PopupMenuItem(
                  child: TextButton(
                    child: Text(
                      "New group",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                    onPressed: () {},
                  ),
                  value: "New group",
                ),
                PopupMenuItem(
                  child: TextButton(
                    child: Text(
                      "Web",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                    onPressed: () {},
                  ),
                  value: "Web",
                ),
                PopupMenuItem(
                  child: TextButton(
                    child: Text(
                      "Starred messages",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                    onPressed: () {},
                  ),
                  value: "Starred messages",
                ),
                PopupMenuItem(
                  child: TextButton(
                    child: Text(
                      "Settings",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                    onPressed: () {},
                  ),
                  value: "Settings",
                ),
                PopupMenuItem(
                  child: TextButton(
                    child: Text(
                      "Logout",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Landing()),
                      );
                    },
                  ),
                  value: "Logout",
                ),
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: (isLoading == true)
              ? Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(5),
                          style: SkeletonStyle.text,
                          textColor: Colors.grey.shade300,
                          height: 88,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  child: chatRoomsList(),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.comment,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(CreateRoute(page: Search()));
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  DateTime val = DateTime.parse(new DateFormat('yyyy-MM-dd').format(new DateTime.now()));
  String today = '';

  ChatRoomsTile({required this.userName, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CreateRoute(
            page: Chat(
          chatRoomId: chatRoomId,
          username: userName,
        )));
      },
      child: Card(
        elevation: 3,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Color(0xff007EF4), borderRadius: BorderRadius.circular(30)),
                    child: Text(userName.substring(0, 1).toUpperCase(),
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).collection("chats").orderBy('time').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    var length = snapshot.data!.docs.length;
                    var count = length - 1;
                    var message = snapshot.data!.docs[count]["message"];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(userName[0].toUpperCase() + userName.substring(1),
                            textAlign: TextAlign.justify, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                        SizedBox(
                          height: 5,
                        ),
                        (message == null)
                            ? Row(
                                children: [
                                  Container(
                                    alignment: Alignment.topCenter,
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          snapshot.data!.docs[count]['image'][0],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      'Photo',
                                      style: TextStyle(color: Colors.blue, fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 175,
                                      child: Text(message,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400)),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    );
                  }),
              Spacer(),
              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).collection("chats").orderBy('time').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    var length = snapshot.data!.docs.length;
                    var count = length - 1;
                    var date = snapshot.data!.docs[count]["Date"].toString();
                    var _date = DateFormat('yyyy-MM-dd', 'en_US').parseLoose(date);
                    if (_date.isAtSameMomentAs(val)) {
                      today = "Today";
                    } else {
                      today = snapshot.data!.docs[count]["date"].toString();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        (today == 'Today')
                            ? Container(
                                child: Text(
                                  snapshot.data!.docs[count]['msgtime'],
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              )
                            : Container(
                                child: Text(
                                  snapshot.data!.docs[count]['date'],
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class Constants {
  static String myName = "";
}
