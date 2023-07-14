import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IndividualChat extends StatelessWidget {
  final String roomId;

  IndividualChat({super.key, required this.roomId, required this.userMap});

  final Map<String, dynamic> userMap;
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_message.text.isNotEmpty) {
      await _firestore
          .collection('chatroom')
          .doc(roomId)
          .collection('chats')
          .add(
        {
          "sendBy": _auth.currentUser!.displayName,
          "message": _message.text,
          "time": FieldValue.serverTimestamp(),
        },
      );
      print("message sent");
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(userMap['name']),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('chatroom')
              .doc(roomId)
              .collection('chats')
              .orderBy("time", descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.data!.docs[index].data() == null) {
                    print("data is null");
                    return Container();
                  }
                  print("data is present");
                  return Container(
                    width: 300,
                    alignment: snapshot.data!.docs[index]["sendBy"] ==
                            _auth.currentUser!.displayName
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      margin:const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue,
                      ),
                      child: Text(
                        snapshot.data!.docs[index]['message'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Container();
            }
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      sendMessage();
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
