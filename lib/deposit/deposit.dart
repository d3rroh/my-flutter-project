import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_apps/utils/loading.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:intl/intl.dart';

import '../menu.dart';

class depositScreen extends StatefulWidget {
  depositScreen({Key? key}) : super(key: key);

  @override
  _depositScreenState createState() => _depositScreenState();
}

class _depositScreenState extends State<depositScreen> {
  TextEditingController _amount = new TextEditingController();
  TextEditingController memNumber = new TextEditingController();
  late String name;
  FirebaseAuth auth = FirebaseAuth.instance;
  late double amount;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool loading = false;

  Random random = new Random();
  late int randomNumber;

  depositMoney(double amount) {
    setState(() {
      loading = true;
    });

    String numAmount = _amount.text.trim();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    //var doubleAmount = double.parse('amount');
    final User? user = auth.currentUser;
    final uid = user!.uid;

    randomNumber = random.nextInt(200000);
    String transID = randomNumber.toString();
    String transName = 'Deposit';

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(uid);

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (!snapshot.exists) {
            setState(() {
              loading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('USER DOES NOT EXIST'),
            ));
            throw Exception("User does not exist!");
          }

          double newBalance;

          newBalance = snapshot['Balance'] + amount;
          transaction.update(documentReference, {'Balance': newBalance});

          String first_name = snapshot['First_name'];
          String last_name = snapshot['Last_name'];
          String idNumber = snapshot['idNum'];

          await _firestore.collection("Transactions").doc().set(
            {
              'First_name': first_name,
              'Last_name': last_name,
              'UID': uid,
              'idnum': idNumber,
              'date': formatted,
              'Amount_deposited': amount,
              'new_Balance': newBalance,
              'Transaction_Name': transName,
            },
          );

          _createPDF(first_name, last_name, idNumber, numAmount, formatted,
              transID, newBalance);
          setState(() {
            loading = false;
          });

          return newBalance;
        })
        .then((value) => print("Member count updated to $value"))
        .catchError(
            (error) => print("Failed to update user followers: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('DEPOSIT MONEY'),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  //MEMBER NUMBER

                  Container(
                    child: Text(
                      'ENTER THE AMOUNT YOU WANT TO DEPOSIT',
                      style: TextStyle(
                        fontSize: 20,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.blue,
                      ),
                    ),
                  ),

//AMOUNT

                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffEEEEEE),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 20),
                            blurRadius: 100,
                            color: Color(0xffEEEEEE)),
                      ],
                    ),
                    child: TextFormField(
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        focusColor: Colors.blue,
                        icon: Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.blue,
                        ),
                        hintText: "Enter Amount",
                        labelText: 'Enter Amount',
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      controller: _amount,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter Amount';
                        }
                      },
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      String numd = _amount.text.trim();
                      var der = double.parse(numd);
                      depositMoney(der);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 20, right: 20, top: 70),
                      padding: EdgeInsets.only(left: 20, right: 20),
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              (new Color(0xff2A87FF)),
                              new Color(0xff00BFFF)
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
                        "DEPOSIT",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
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
                      margin: EdgeInsets.only(left: 20, right: 20, top: 70),
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

Future<void> _createPDF(String first_name, String last_name, String idnum,
    String amount, String date, String transID, double newAmount) async {
  //Create a new PDF document
  PdfDocument document = PdfDocument();

  //Add a new page and draw text
  PdfPage page = document.pages.add();

//Draw the image to the PDF page.
  page.graphics.drawImage(PdfBitmap(await _readImageData('15.png')),
      Rect.fromLTWH(200, 10, 100, 100));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Deposit',
    Rect.fromLTWH(380, 0, 130, 20),
    text: 'Date: ' + date,
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Deposit',
    Rect.fromLTWH(380, 20, 130, 20),
    text: 'Receipt NO: RC' + transID,
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Names',
    Rect.fromLTWH(200, 100, 100, 20),
    text: 'NACICO SOCIETY SACCO ',
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Date',
    Rect.fromLTWH(200, 120, 100, 20),
    text: 'P.O BOX 1234,',
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Deposit',
    Rect.fromLTWH(200, 140, 100, 20),
    text: 'NAIROBI',
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Balance',
    Rect.fromLTWH(200, 160, 200, 20),
    text: 'DEPOSIT RECEIPT',
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Deposit',
    Rect.fromLTWH(0, 180, 300, 20),
    text: 'NAME: ' + first_name + ' ' + last_name,
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'ID N0: ',
    Rect.fromLTWH(0, 200, 130, 20),
    text: 'ID NO: ' + idnum,
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Deposit',
    Rect.fromLTWH(0, 220, 200, 20),
    text: 'Money Deposited: ' + amount,
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  document.form.fields.add(PdfTextBoxField(
    page,
    'Deposit',
    Rect.fromLTWH(0, 240, 200, 20),
    text: 'New Balance: ' + newAmount.toStringAsFixed(3),
    borderColor: PdfColor(255, 255, 255),
    font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
  ));

  //Save the document
  List<int> bytes = document.save();

  //Dispose the document
  document.dispose();

  //Get external storage directory
  final directory = await getExternalStorageDirectory();

  //Get directory path
  final path = directory!.path;

  //Create an empty file to write PDF data
  File file = File('$path/Output.pdf');

  //Write PDF data
  await file.writeAsBytes(bytes, flush: true);

  //Open the PDF document in mobile
  OpenFile.open('$path/Output.pdf');
}

Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load('assets/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
