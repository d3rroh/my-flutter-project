import 'package:cloud_firestore/cloud_firestore.dart';

class dbServices {
  final String uid;
  dbServices({required this.uid});

  final CollectionReference detailCollection =
      FirebaseFirestore.instance.collection('userDetails');
  Future updateUsers(
      String Name, String dob, String LocAddress, String IdNumber) async {
    return detailCollection
        .add({
          'full_name': Name,
          'DOB': dob,
          'Address': LocAddress,
          'ID_Number': IdNumber,
        })
        .then((value) => print('user added'))
        .catchError((error) => print('Failed to add user:$error'));
  }
}
