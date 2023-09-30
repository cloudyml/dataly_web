import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServices {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserById(String id) => _firestore
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((doc) {
        print("useridhere: ${FirebaseAuth.instance.currentUser!.uid}");
        print("jeojsod:${doc.exists}");
        return UserModel.fromSnapShot(doc);
      });
}
