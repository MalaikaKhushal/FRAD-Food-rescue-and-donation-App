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
  // RESET / FORGOT PASSWORD
  // ===========================

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        "success": true,
        "message": "Password reset link has been sent to $email",
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 'user-not-found') {
        errorMessage = "No user registered with this email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      return {"success": false, "message": errorMessage};
    } catch (e) {
      return {"success": false, "message": "Error: ${e.toString()}"};
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
