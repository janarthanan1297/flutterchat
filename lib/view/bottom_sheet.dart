import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutterchat/view/chatroom.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MyBottomSheet extends StatefulWidget {
  final String chatRoomId;

  MyBottomSheet({required this.chatRoomId});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  List<XFile>? images = [];
  final ImagePicker _picker = ImagePicker();
  CollectionReference? imgRef;
  CollectionReference? refer;
  double val = 0;

  imageSelectorGallery() async {
    final galleryFile = await _picker.pickMultiImage(
      imageQuality: 40,
    );
    setState(() {
      images = galleryFile;
    });
  }

  imageSelectorCamera() async {
    final galleryFile2 = await _picker.pickImage(source: ImageSource.camera, imageQuality: 40);
    setState(() {
      images!.add(galleryFile2!);
    });
  }

  Future upload() async {
    List<String> _imageUrls = [];
    int i = 1;
    for (var img in images!) {
      setState(() {
        val = i / images!.length;
      });
      final Reference storageReference = FirebaseStorage.instance.ref().child('images/${Path.basename(img.path)}');
      await storageReference.putFile(File(img.path)).whenComplete(() async {
        await storageReference.getDownloadURL().then((value) {
          _imageUrls.add(value);
          i++;
        });
      });
    }
    FirebaseFirestore.instance.collection("chatRoom").doc(widget.chatRoomId).collection("chats").add({
      "sendBy": Constants.myName,
      "message": null,
      'image': _imageUrls,
      'time': DateTime.now().millisecondsSinceEpoch,
      'msgtime': formatDate(DateTime.now(), [hh, ':', nn, " ", am]).toString(),
      'Date': new DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'date': new DateFormat.yMMMd().format(DateTime.now())
    }).whenComplete(() => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 270,
          child: GridView.count(
            crossAxisSpacing: 0,
            mainAxisSpacing: 5,
            crossAxisCount: 3,
            children: List.generate(images!.length, (index) {
              return Column(children: <Widget>[
                Container(
                    height: 90,
                    width: 125,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      child: Image.file(File(images![index].path), fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(10),
                    )),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      images!.removeAt(index);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Icon(Icons.clear, color: Colors.black, size: 30),
                    ),
                  ),
                ),
              ]);
            }),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              child: Container(
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0xff5157af), borderRadius: BorderRadius.circular(30)),
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.white,
                  )),
            ),
            GestureDetector(
              onTap: () {
                imageSelectorCamera();
              },
              child: Container(
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0xffd3396d), borderRadius: BorderRadius.circular(30)),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  )),
            ),
            GestureDetector(
              onTap: () {
                imageSelectorGallery();
              },
              child: Container(
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0xffad45d0), borderRadius: BorderRadius.circular(30)),
                  child: Icon(
                    Icons.image,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 01),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 149,
                height: 37,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Color(0xff25D366), width: 2)),
                child: Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff25D366),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            SizedBox(width: 01),
            InkWell(
              onTap: () {
                upload();
              },
              child: Container(
                width: 149,
                height: 37,
                decoration: BoxDecoration(color: Color(0xff25D366), borderRadius: BorderRadius.circular(15), boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: const Offset(0.0, 5.0),
                  )
                ]),
                child: Center(
                  child: Text(
                    "Send",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            SizedBox(width: 01)
          ],
        )
      ],
    );
  }
}
