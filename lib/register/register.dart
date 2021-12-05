import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_apps/camera.dart';
import 'package:flutter_apps/menu.dart';
import 'package:flutter_apps/utils/loading.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:flutter_sms/flutter_sms.dart';

class registerScreen extends StatefulWidget {
  registerScreen({Key? key}) : super(key: key);

  @override
  _registerScreenState createState() => _registerScreenState();
}

class _registerScreenState extends State<registerScreen> {
  DateTime selectedDate = DateTime.now();
  double balance = 0.00;
  String? phoneNumber;
  String? phoneIsoCode;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var verificationCode = '';
  TextEditingController fname = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController idnum = new TextEditingController();
  TextEditingController lname = new TextEditingController();
  TextEditingController location = new TextEditingController();
  bool loading = false;
  final TextEditingController _pinOTPCodeController = TextEditingController();
  final FocusNode _pinOTPCodeFocus = FocusNode();

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    print(internationalizedPhoneNumber);
    setState(() {
      phoneNumber = internationalizedPhoneNumber;
      phoneIsoCode = isoCode;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future signUp(String phoneNumber) async {
    setState(() {
      loading = true;
    });

    var verifyPhoneNumber = _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) {
          _auth.signInWithCredential(phoneAuthCredential).then((user) async => {
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .set({
                  'names': fname.text.trim(),
                  'idNum': idnum.text.trim(),
                  'DOB': DateTime,
                  'Balance': balance.toString(),
                })
              });
        },
        verificationFailed: (FirebaseAuthException error) {
          debugPrint('error');
        },
        codeSent: (verificationId, [forceResendingToken]) {
          String message =
              "Thank you for registering with NACICO Sacco deposit an amount to activate your account";
          List<String> recipents = [phoneNumber];
          final codeVer = TextEditingController();

          String newDate =
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text('Enter Verification Code Text'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: PinPut(
                            fieldsCount: 6,
                            textStyle:
                                TextStyle(fontSize: 15.0, color: Colors.blue),
                            eachFieldHeight: 15.0,
                            eachFieldWidth: 10.0,
                            focusNode: _pinOTPCodeFocus,
                            controller: _pinOTPCodeController,
                            submittedFieldDecoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blue),
                            ),
                            selectedFieldDecoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blue),
                            ),
                            followingFieldDecoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blue),
                            ),
                            pinAnimationType: PinAnimationType.rotation,
                            onSubmit: (pin) async {
                              var credential = PhoneAuthProvider.credential(
                                  verificationId: verificationId, smsCode: pin);
                              _auth
                                  .signInWithCredential(credential)
                                  .then((user) async => {
                                        if (user != null)
                                          {
                                            await _firestore
                                                .collection('users')
                                                .doc(_auth.currentUser!.uid)
                                                .set({
                                              'First_name': fname.text.trim(),
                                              'Last_name': lname.text.trim(),
                                              'idNum': idnum.text.trim(),
                                              'Balance': balance,
                                              'DOB': newDate,
                                              'phoneNumber': phoneNumber,
                                              'Address': address.text.trim(),
                                              'Location': location.text.trim(),
                                            }, SetOptions(merge: true)).then(
                                                    (value) => {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                'MEMBER REGISTERED'),
                                                            duration: Duration(
                                                                seconds: 3),
                                                          )),
                                                          loading = false,
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => cameraScreen(
                                                                      name: fname
                                                                          .text
                                                                          .trim())))
                                                        })
                                          }
                                        else
                                          {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content:
                                                  Text('USER NOT VERIFIED'),
                                              duration: Duration(seconds: 3),
                                            )),
                                            setState(() {
                                              loading = false;
                                            }),
                                          }
                                      });
                            },
                          ),
                        )
                      ],
                    ),
                  ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationCode = verificationId;
        });

    await verifyPhoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('REGISTER MEMBER'),
            ),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    //f_name
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
                            Icons.person,
                            color: Colors.blue,
                          ),
                          hintText: "First Name",
                          labelText: 'Enter Your First Name',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter Amount';
                          }
                        },
                        controller: fname,
                      ),
                    ),

                    //Last name

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
                            Icons.person,
                            color: Colors.blue,
                          ),
                          hintText: "Last Name",
                          labelText: 'Enter Your Last Name',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter Amount';
                          }
                        },
                        controller: lname,
                      ),
                    ),

                    //date

                    RaisedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text("Choose Date"),
                    ),
                    Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),

                    //mobile

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
                      child: InternationalPhoneInput(
                          decoration: InputDecoration.collapsed(
                              hintText: 'Enter Phone Number'),
                          onPhoneNumberChange: onPhoneNumberChange,
                          initialPhoneNumber: phoneNumber,
                          initialSelection: 'Ke',
                          enabledCountries: ['+254'],
                          showCountryCodes: true),
                    ),

                    //ID number

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
                            Icons.person_pin_outlined,
                            color: Colors.blue,
                          ),
                          hintText: "Enter ID Number",
                          labelText: 'Enter ID Number',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter Amount';
                          }
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        controller: idnum,
                      ),
                    ),

                    //address

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
                            Icons.person,
                            color: Colors.blue,
                          ),
                          hintText: "ADDRESS",
                          labelText: 'Enter the Address',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter Amount';
                          }
                        },
                        controller: address,
                      ),
                    ),

                    //location
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
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                          hintText: "LOCATION",
                          labelText: 'Enter the Location',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter Amount';
                          }
                        },
                        controller: location,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        signUp(phoneNumber!);
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
                          "NEXT",
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

void _sendSMS(String message, List<String> recipents) async {
  String _result = await sendSMS(message: message, recipients: recipents)
      .catchError((onError) {
    print(onError);
  });
  print(_result);
}
