import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../menu.dart';

class accNumScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<accNumScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('MEMBER ACCOUNT'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(left: 10, right: 10, top: 0),
          child: Column(
            children: [
              Container(
                child: Image.asset(
                  "assets/15.png",
                  height: 200,
                  width: 200,
                ),
              ),
              Text(
                'MEMBER DETAILS',
                style: TextStyle(
                  fontSize: 20,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.blue,
                ),
              ),
              Container(
                height: 250,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: FutureBuilder<DocumentSnapshot>(
                  future: users.doc(auth.currentUser!.uid).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }
                    if (snapshot.hasData && !snapshot.data!.exists) {
                      return Text("Document does not exist");
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      String balance = '${data['Balance']}';
                      var doubleBalance = double.parse(balance);
                      double bookBalance = doubleBalance - 500;
                      String imageUrl = '${data['IDCardPath']}';
                      return Column(
                        children: [
                          Container(
                            child: Text(
                              'NAME: ${data['First_name']}',
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              'ID NO: ${data['Last_name']}',
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              'PHONE NO: ${data['phoneNumber']}',
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              'DOB: ${data['DOB']}',
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              'BALANCE: ${data['Balance']}',
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              'ADDRESS' + bookBalance.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              'LOCATION: ${data['Location']}',
                              style: TextStyle(
                                fontSize: 15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.5
                                  ..color = Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            height: 99,
                            width: 150,
                            margin: EdgeInsets.only(left: 0, right: 0, top: 20),
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Image.network(imageUrl, fit: BoxFit.fill,),
                          ),


                        ],
                      );
                    }
                    return Text('Loading');
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => menuScreen()));
                  auth.signOut();
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 0),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          (new Color(0xFF185BB3)),
                          new Color(0xFF7DD3F0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: Color(0xffEEEEEE)),
                    ],
                  ),
                  child: Text(
                    "BACK TO MAIN MENU",
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
