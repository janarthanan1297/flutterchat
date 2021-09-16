import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/data/database.dart';
import 'package:flutterchat/view/Landing.dart';
import 'package:flutterchat/view/chat.dart';
import 'package:flutterchat/view/chatroom.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  late QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods.searchByName(searchEditingController.text).then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.docs[index]["userName"],
                searchResultSnapshot.docs[index]["userEmail"],
              );
            })
        : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName) {
    List<String> users = [Constants.myName, userName];

    String chatRoomId = getChatRoomId(Constants.myName, userName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  chatRoomId: chatRoomId,
                  username: userName,
                )));
  }

  Widget userTile(String userName, String userEmail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Container(
                child: Text(
                  userEmail,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              sendMessage(userName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 07, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FlutterChat",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21, color: Colors.white),
        ),
        elevation: 3.0,
        centerTitle: false,
        actions: [
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
                      "Whatsapp Web",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,
                    ),
                    onPressed: () {},
                  ),
                  value: "Whatsapp Web",
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
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.16),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchEditingController,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            decoration: InputDecoration(
                                hintText: "Search username ...",
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [const Color(0x36FFFFFF), const Color(0x0FFFFFFF)],
                                      begin: FractionalOffset.topLeft,
                                      end: FractionalOffset.bottomRight),
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(12),
                              child: Image.asset(
                                "assets/image/search_white.png",
                                height: 25,
                                width: 25,
                              )),
                        )
                      ],
                    ),
                  ),
                  userList()
                ],
              ),
            ),
    );
  }
}
