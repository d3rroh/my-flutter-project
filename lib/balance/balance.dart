import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../menu.dart';

class balanceScreen extends StatefulWidget {
  balanceScreen({Key? key}) : super(key: key);

  @override
  _balanceScreenState createState() => _balanceScreenState();
}

class _balanceScreenState extends State<balanceScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACCOUNT BALANCE'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
              'ACCOUNT BALANCE',
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
    );
  }
}
