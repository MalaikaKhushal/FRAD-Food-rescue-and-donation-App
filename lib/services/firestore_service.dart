import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Add these methods inside your FirestoreService class (firestore_service.dart)

  /// Call this whenever a provider successfully adds a new food listing.
  /// It creates a notification document that all receivers/customers can see.
  Future<void> createNewFoodNotification({
    required String foodName,
    required String providerName,
    required String location,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'New Food Available!',
      'message': '$providerName just posted "$foodName" near $location',
      'targetRole': 'receiver', // only customers/receivers should see this
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': <String>[], // list of userIds who have seen/read this
    });
  }

  /// Stream of notifications relevant to the current logged-in user's role.
  /// Pass 'receiver' on the customer dashboard, 'provider' on the provider dashboard.
  Stream<QuerySnapshot> getNotificationsForRole(String role) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('targetRole', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots();
  }

  /// Marks a notification as read by the current user (so the badge count drops).
  Future<void> markNotificationRead(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({
          'readBy': FieldValue.arrayUnion([uid]),
        });
  }

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  User? get currentUser => _auth.currentUser;

  // ==========================================================
  // GET CURRENT USER DATA
  // ==========================================================

  Future<UserModel> getCurrentUserData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("users")
          .doc(currentUser!.uid)
          .get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Error getting user data: $e");
    }
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
              .map(
                (doc) => FoodModel.fromMap(doc.data() as Map<String, dynamic>),
              )
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
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FoodModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  // ==========================================================
  // GET PROVIDER FOOD
  // ==========================================================

  Stream<List<FoodModel>> getProviderFood() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection("food_listings")
        .where("providerId", isEqualTo: currentUser!.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FoodModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  // ==========================================================
  // ADD FOOD
  // ==========================================================

  Future<String> addFood(FoodModel food) async {
    try {
      if (food.foodId.isEmpty) {
        throw Exception("Food ID cannot be empty");
      }

      await _firestore
          .collection("food_listings")
          .doc(food.foodId)
          .set(food.toMap());

      return "success";
    } catch (e) {
      return "Error adding food: ${e.toString()}";
    }
  }

  // ==========================================================
  // UPDATE FOOD (✅ FIXED - Using Timestamp)
  // ==========================================================

  Future<String> updateFood(String foodId, Map<String, dynamic> data) async {
    try {
      if (foodId.isEmpty) {
        throw Exception("Food ID cannot be empty");
      }

      // Remove updatedAt if it already exists in data
      data.remove("updatedAt");

      await _firestore.collection("food_listings").doc(foodId).update({
        ...data,
        "updatedAt": Timestamp.now(), // ✅ Use Timestamp.now()
      });

      return "success";
    } catch (e) {
      return "Error updating food: ${e.toString()}";
    }
  }

  // ==========================================================
  // DELETE FOOD
  // ==========================================================

  Future<String> deleteFood(String foodId) async {
    try {
      if (foodId.isEmpty) {
        throw Exception("Food ID cannot be empty");
      }

      await _firestore.collection("food_listings").doc(foodId).delete();

      return "success";
    } catch (e) {
      return "Error deleting food: ${e.toString()}";
    }
  }

  // ==========================================================
  // RESERVE FOOD (✅ FIXED - Using Timestamp)
  // ==========================================================

  Future<String> reserveFood({
    required String foodId,
    required String providerId,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      String reservationId = _firestore.collection("reservations").doc().id;

      await _firestore.collection("reservations").doc(reservationId).set({
        "reservationId": reservationId,
        "foodId": foodId,
        "customerId": currentUser!.uid,
        "providerId": providerId,
        "status": "Pending",
        "reservedAt": Timestamp.now(), // ✅ Use Timestamp.now()
      });

      return "success";
    } catch (e) {
      return "Error reserving food: ${e.toString()}";
    }
  }

  // ==========================================================
  // CUSTOMER RESERVATIONS
  // ==========================================================

  Stream<QuerySnapshot> getCustomerReservations() {
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("reservations")
        .where("customerId", isEqualTo: currentUser!.uid)
        .orderBy("reservedAt", descending: true)
        .snapshots();
  }

  // ==========================================================
  // PROVIDER RESERVATIONS
  // ==========================================================

  Stream<QuerySnapshot> getProviderReservations() {
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("reservations")
        .where("providerId", isEqualTo: currentUser!.uid)
        .orderBy("reservedAt", descending: true)
        .snapshots();
  }

  // ==========================================================
  // COMPLETE ORDER (✅ FIXED - Using Timestamp)
  // ==========================================================

  Future<String> completeOrder(String reservationId) async {
    try {
      await _firestore.collection("reservations").doc(reservationId).update({
        "status": "Completed",
        "completedAt": Timestamp.now(), // ✅ Use Timestamp.now()
      });
      return "success";
    } catch (e) {
      return "Error completing order: ${e.toString()}";
    }
  }

  // ==========================================================
  // CANCEL ORDER (✅ FIXED - Using Timestamp)
  // ==========================================================

  Future<String> cancelOrder(String reservationId) async {
    try {
      await _firestore.collection("reservations").doc(reservationId).update({
        "status": "Cancelled",
        "cancelledAt": Timestamp.now(), // ✅ Use Timestamp.now()
      });
      return "success";
    } catch (e) {
      return "Error cancelling order: ${e.toString()}";
    }
  }

  // ==========================================================
  // TOTAL FOOD LISTINGS
  // ==========================================================

  Stream<int> getTotalListings() {
    if (currentUser == null) {
      return Stream.value(0);
    }

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
    if (currentUser == null) {
      return Stream.value(0);
    }

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
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection("food_listings")
        .where("providerId", isEqualTo: currentUser!.uid)
        .where("donation", isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==========================================================
  // GET FOOD BY ID
  // ==========================================================

  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("food_listings")
          .doc(foodId)
          .get();

      if (doc.exists) {
        return FoodModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Error getting food: $e");
    }
  }

  Future<String> uploadFoodImage(File imageFile, String foodId) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("food_images").child("$foodId.jpg");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Storage Error: $e");
      return "";
    }
  }

  Future<void> acceptReservation(String reservationId) async {
    await _firestore.collection("reservations").doc(reservationId).update({
      "status": "Accepted",
    });
  }

  Future<void> readyReservation(String reservationId) async {
    await _firestore.collection("reservations").doc(reservationId).update({
      "status": "Ready",
    });
  }

  // ==========================================================
  // NOTIFY CUSTOMER — ORDER STATUS UPDATE
  // ==========================================================
  Future<void> notifyCustomerOrderStatus({
    required String customerId,
    required String foodName,
    required String status,
  }) async {
    String message;
    switch (status) {
      case "Accepted":
        message = 'Your order for "$foodName" has been accepted!';
        break;
      case "Ready":
        message = '"$foodName" is ready for pickup!';
        break;
      case "Completed":
        message = 'Your order for "$foodName" is complete. Enjoy!';
        break;
      case "Cancelled":
        message = 'Your order for "$foodName" was cancelled.';
        break;
      default:
        message = 'Your order for "$foodName" was updated to $status.';
    }

    await _firestore.collection('notifications').add({
      'title': 'Order Update',
      'message': message,
      'targetRole': 'receiver',
      'targetUserId': customerId,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': <String>[],
    });
  }
}
