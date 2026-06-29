import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================
  // SIGN UP
  // ===========================

  Future<String> signUpUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "fullName": fullName,
          "email": email,
          "phone": phone,
          "role": role,
          "createdAt": Timestamp.now(),
        });

        return "success";
      }

      return "Something went wrong";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Signup Failed";
    } catch (e) {
      return e.toString();
    }
  }

  // ===========================
  // LOGIN
  // ===========================

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = credential.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection("users")
            .doc(user.uid)
            .get();

        return {
          "success": true,
          "role": doc["role"],
          "uid": user.uid,
          "name": doc["fullName"],
        };
      }

      return {"success": false, "message": "Login Failed"};
    } on FirebaseAuthException catch (e) {
      return {"success": false, "message": e.message};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ===========================
  // LOGOUT
  // ===========================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ===========================
  // CURRENT USER
  // ===========================

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
