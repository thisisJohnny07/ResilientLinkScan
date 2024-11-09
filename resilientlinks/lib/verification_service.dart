import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to verify if UID exists in the 'staff' collection
  Future<bool> verifyUID(String uid) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('staff').doc(uid).get();

      if (docSnapshot.exists) {
        // Store verification status as true
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isVerified', true);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error verifying UID: $e');
      return false;
    }
  }

  // Function to sign out and reset the verification status
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVerified', false); // Reset verification status
  }
}
