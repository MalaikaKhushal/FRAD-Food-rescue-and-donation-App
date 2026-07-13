import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  User? get currentUser => _auth.currentUser;

  // ==========================================================
  // GET CURRENT USER DATA
  // ==========================================================

  Future<UserModel> getCurrentUserData() async {
    DocumentSnapshot doc = await _firestore
        .collection("users")
        .doc(currentUser!.uid)
        .get();

    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ==========================================================
  // GET ALL FOOD
  // ==========================================================

  Stream<List<FoodModel>> getAllFood() {
    return _firestore
        .collection("food_listings")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FoodModel.fromMap(doc.data()))
              .toList();
        });
  }

  // ==========================================================
  // GET DONATION FOOD
  // ==========================================================

  Stream<List<FoodModel>> getDonationFood() {
    return _firestore
        .collection("food_listings")
        .where("donation", isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FoodModel.fromMap(doc.data()))
              .toList();
        });
  }

  // ==========================================================
  // GET PROVIDER FOOD
  // ==========================================================

  Stream<List<FoodModel>> getProviderFood() {
    return _firestore
        .collection("food_listings")
        .where("providerId", isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FoodModel.fromMap(doc.data()))
              .toList();
        });
  }

  // ==========================================================
  // ADD FOOD
  // ==========================================================

  Future<String> addFood(FoodModel food) async {
    try {
      await _firestore
          .collection("food_listings")
          .doc(food.foodId)
          .set(food.toMap());

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // UPDATE FOOD
  // ==========================================================

  Future<String> updateFood(String foodId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection("food_listings").doc(foodId).update(data);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // DELETE FOOD
  // ==========================================================

  Future<String> deleteFood(String foodId) async {
    try {
      await _firestore.collection("food_listings").doc(foodId).delete();

      return "success";
    } catch (e) {
      return e.toString();
    }
  }
  // ==========================================================
  // EDIT FOOD
  // ==========================================================

  Future<String> editFood({
    required String foodId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection("food_listings").doc(foodId).update(data);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // RESERVE FOOD
  // ==========================================================

  Future<String> reserveFood({
    required String foodId,
    required String providerId,
  }) async {
    try {
      String reservationId = _firestore.collection("reservations").doc().id;

      await _firestore.collection("reservations").doc(reservationId).set({
        "reservationId": reservationId,
        "foodId": foodId,
        "customerId": currentUser!.uid,
        "providerId": providerId,
        "status": "Reserved",
        "reservedAt": Timestamp.now(),
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // CUSTOMER RESERVATIONS
  // ==========================================================

  Stream<QuerySnapshot> getCustomerReservations() {
    return _firestore
        .collection("reservations")
        .where("customerId", isEqualTo: currentUser!.uid)
        .snapshots();
  }

  // ==========================================================
  // PROVIDER RESERVATIONS
  // ==========================================================

  Stream<QuerySnapshot> getProviderReservations() {
    return _firestore
        .collection("reservations")
        .where("providerId", isEqualTo: currentUser!.uid)
        .snapshots();
  }

  // ==========================================================
  // COMPLETE ORDER
  // ==========================================================

  Future<void> completeOrder(String reservationId) async {
    await _firestore.collection("reservations").doc(reservationId).update({
      "status": "Completed",
    });
  }

  // ==========================================================
  // CANCEL ORDER
  // ==========================================================

  Future<void> cancelOrder(String reservationId) async {
    await _firestore.collection("reservations").doc(reservationId).update({
      "status": "Cancelled",
    });
  }
  // ==========================================================
  // TOTAL FOOD LISTINGS
  // ==========================================================

  Stream<int> getTotalListings() {
    return _firestore
        .collection("food_listings")
        .where("providerId", isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==========================================================
  // TOTAL RESERVATIONS
  // ==========================================================

  Stream<int> getTotalReservations() {
    return _firestore
        .collection("reservations")
        .where("providerId", isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==========================================================
  // TOTAL DONATIONS
  // ==========================================================

  Stream<int> getTotalDonations() {
    return _firestore
        .collection("food_listings")
        .where("providerId", isEqualTo: currentUser!.uid)
        .where("donation", isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
