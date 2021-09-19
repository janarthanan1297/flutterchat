import 'dart:async';
import 'package:flutterchat/view/bottom_sheet.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterchat/data/database.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:swipedetector/swipedetector.dart';
import 'package:flutterchat/view/chatroom.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  final String chatRoomId, username;

  Chat({required this.chatRoomId, required this.username});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = new TextEditingController();
  FocusNode _focusNode1 = FocusNode();
  DateTime val = DateTime.parse(new DateFormat('yyyy-MM-dd').format(new DateTime.now()));
  ScrollController _scrollController = new ScrollController();
  ValueNotifier<String> today = ValueNotifier<String>('');
  var value;
  var visible;

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollController.jumpTo(0.0);
          var date = snapshot.data!.docs[0]["Date"].toString();
          var _date = DateFormat('yyyy-MM-dd', 'en_US').parseLoose(date);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            if (_date.isAtSameMomentAs(val)) {
              today.value = "Today";
            }
          });
        });

        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                reverse: true,
                controller: _scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var length = snapshot.data!.docs.length;
                  var count = length - 1;
                  var date = snapshot.data!.docs[index]["Date"].toString();
                  var _date = DateFormat('yyyy-MM-dd', 'en_US').parseLoose(date);
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    if (_date.isAtSameMomentAs(val)) {
                      today.value = "Today";
                    } else {
                      today.value = snapshot.data!.docs[index]["date"].toString();
                    }
                  });
                  if (value != _date) {
                    value = _date;
                    visible = true;
                  } else {
                    visible = false;
                  }

                  return (snapshot.data!.docs[index]["message"] == null)
                      ? ImageTile(
                          sendByMe: Constants.myName == snapshot.data!.docs[index]["sendBy"],
                          time: snapshot.data!.docs[index]["msgtime"],
                          chatRoomId: widget.chatRoomId,
                          index: index,
                          visible: visible,
                        )
                      : MessageTile(
                          message: snapshot.data!.docs[index]["message"],
                          sendByMe: Constants.myName == snapshot.data!.docs[index]["sendBy"],
                          time: snapshot.data!.docs[index]["msgtime"],
                          index: index,
                          length: count,
                          visible: visible,
                        );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
        'msgtime': formatDate(DateTime.now(), [hh, ':', nn, " ", am]).toString(),
        'Date': new DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'date': new DateFormat.yMMMd().format(DateTime.now())
      };
      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  Future<void> _filter() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => MyBottomSheet(
        chatRoomId: widget.chatRoomId,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffece5dd),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Color(0xff007EF4), borderRadius: BorderRadius.circular(30)),
              child: Text(widget.username.substring(0, 1).toUpperCase(),
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            SizedBox(
              width: 15,
            ),
            Text(widget.username[0].toUpperCase() + widget.username.substring(1),
                textAlign: TextAlign.justify, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500))
          ],
        ),
        elevation: 3.0,
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child: Stack(
            children: [
              chatMessages(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(5)),
                    child: ValueListenableBuilder(
                      valueListenable: today,
                      builder: (BuildContext context, String value, Widget? child) {
                        return Text(
                          today.value,
                          style: TextStyle(fontSize: 16),
                        );
                      },
                    )),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Flexible(
                          child: Container(
                        padding: EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(25)), boxShadow: []),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageEditingController,
                                keyboardType: TextInputType.multiline,
                                focusNode: _focusNode1,
                                onEditingComplete: (() {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                }),
                                minLines: 1,
                                maxLines: null,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                    hintText: "Type a Message ...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _filter();
                              },
                              child: Container(
                                  height: 48,
                                  width: 45,
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    color: Colors.grey,
                                  )),
                            ),
                          ],
                        ),
                      )),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          addMessage();
                        },
                        child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(color: Color(0xff128C7E), borderRadius: BorderRadius.circular(40)),
                            padding: EdgeInsets.all(0),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message, time;
  final bool sendByMe, visible;
  final int index, length;
  MessageTile({required this.message, required this.sendByMe, required this.time, required this.index, required this.length, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 0, left: sendByMe ? 0 : 20, right: sendByMe ? 20 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
              margin: sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 05),
              decoration: BoxDecoration(
                  borderRadius: sendByMe
                      ? BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15))
                      : BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                  gradient: LinearGradient(
                    colors: sendByMe ? [const Color(0xffdcf8c6), const Color(0xffdcf8c6)] : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(message + '           ', style: TextStyle(color: Colors.black, fontSize: 16)),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  )
                  /* RichText(
                    text: TextSpan(text: message + '   ', style: TextStyle(color: Colors.black, fontSize: 16), children: <TextSpan>[
                      TextSpan(
                        text: time,
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      )
                    ]),
                  ), */
                ],
              )),
        ),
        SizedBox(
          height: (index == 0) ? 100 : 0,
        )
      ],
    );
  }
}

class ImageTile extends StatefulWidget {
  final String time, chatRoomId;
  final bool sendByMe, visible;
  final int index;

  ImageTile({required this.sendByMe, required this.time, required this.chatRoomId, required this.index, required this.visible});
  @override
  _ImageTileState createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  Stream<QuerySnapshot>? chats;

  @override
  void initState() {
    super.initState();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  void _showimg(BuildContext context, int index1, int length) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatRoom")
                  .doc(widget.chatRoomId)
                  .collection("chats")
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Hero(
                      tag: 'my-hero-animation-tag',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          Row(
                            children: [
                              Spacer(),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 30, right: 15),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white54,
                                    child: Padding(
                                      padding: const EdgeInsets.only(),
                                      child: IconButton(
                                        icon: Icon(Icons.arrow_back_ios),
                                        iconSize: 22,
                                        color: Colors.black,
                                        splashColor: Color(0xff25D366),
                                        onPressed: () {
                                          index1 = index1 - 1;
                                          if (index1 >= 0 && index1 < length) {
                                            Navigator.pop(context);
                                            _showimg(context, index1, length);
                                          } else {
                                            index1 = 0;
                                          }
                                        },
                                      ),
                                    ),
                                  )),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 30, right: 15),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white54,
                                    child: Padding(
                                      padding: const EdgeInsets.only(),
                                      child: IconButton(
                                        icon: Icon(Icons.arrow_forward_ios),
                                        iconSize: 22,
                                        color: Colors.black,
                                        splashColor: Color(0xff25D366),
                                        onPressed: () {
                                          index1 = index1 + 1;
                                          if (index1 >= 0 && index1 < length) {
                                            Navigator.pop(context);
                                            _showimg(context, index1, length);
                                          } else {
                                            index1 = length - 1;
                                          }
                                        },
                                      ),
                                    ),
                                  )),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 30, right: 15),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white54,
                                    child: Padding(
                                      padding: const EdgeInsets.only(),
                                      child: IconButton(
                                        icon: Icon(Icons.close),
                                        iconSize: 22,
                                        color: Colors.black,
                                        splashColor: Colors.blue,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          SwipeDetector(
                            onSwipeRight: () {
                              index1 = index1 - 1;
                              if (index1 >= 0 && index1 < length) {
                                Navigator.pop(context);
                                _showimg(context, index1, length);
                              } else {
                                index1 = 0;
                              }
                            },
                            onSwipeLeft: () {
                              index1 = index1 + 1;
                              if (index1 >= 0 && index1 < length) {
                                Navigator.pop(context);
                                _showimg(context, index1, length);
                              } else {
                                index1 = length - 1;
                              }
                            },
                            child: Container(
                              height: 400,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(05),
                                border: Border.all(
                                  color: Color(0xff707070),
                                  width: 1,
                                ),
                                image: DecorationImage(image: NetworkImage(snapshot.data!.docs[widget.index]['image'][index1]), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: chats,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var length = snapshot.data!.docs.length;
          if (length == 0) {
            return Container();
          }
          return Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 0, left: widget.sendByMe ? 0 : 20, right: widget.sendByMe ? 20 : 0),
                alignment: widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                    margin: widget.sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: widget.sendByMe
                            ? BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15))
                            : BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        gradient: LinearGradient(
                          colors: widget.sendByMe
                              ? [const Color(0xffdcf8c6), const Color(0xffdcf8c6)]
                              : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
                        )),
                    child: Column(
                      crossAxisAlignment: widget.sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.end,
                      children: [
                        Container(
                            padding: EdgeInsets.only(top: 10.0),
                            height: 150,
                            width: 150,
                            child: GridView.count(
                                crossAxisCount: (snapshot.data!.docs[widget.index]['image'].length < 2) ? 1 : 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10,
                                scrollDirection: Axis.vertical,
                                children: List.generate(snapshot.data!.docs[widget.index]['image'].length, (index1) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showimg(context, index1, snapshot.data!.docs[widget.index]['image'].length);
                                    },
                                    child: Container(
                                      alignment: Alignment.topCenter,
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            snapshot.data!.docs[widget.index]['image'][index1],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }))),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.time,
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    )),
              ),
              SizedBox(
                height: (widget.index == 0) ? 100 : 0,
              )
            ],
          );
        });
  }
}
