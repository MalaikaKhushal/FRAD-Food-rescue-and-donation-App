import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/food_model.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================================
  // ORIGINAL & UPDATED NOTIFICATION METHODS
  // ==========================================================

  /// Call this whenever a provider successfully adds a new food listing.
  Future<void> createNewFoodNotification({
    required String foodName,
    required String providerName,
    required String location,
  }) async {
    await _firestore.collection('notifications').add({
      'title': 'New Food Available!',
      'message': '$providerName just posted "$foodName" near $location',
      'targetRole': 'receiver', // only customers/receivers should see this
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': <String>[], // list of userIds who have seen/read this
    });
  }

  /// Stream of notifications relevant to the current logged-in user's role.
  Stream<List<NotificationModel>> getNotificationsForRole(String role) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    var query = _firestore
        .collection('notifications')
        .where('targetRole', isEqualTo: role);

    // Agar provider hai toh sirf uski apni specific reservations notifications dikhao
    if (role == 'provider') {
      query = query.where('targetUserId', isEqualTo: user.uid);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// Marks a notification as read by the current user (so the badge count drops).
  Future<void> markNotificationRead(String notificationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'readBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('notificationId', isEqualTo: notificationId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'readBy': FieldValue.arrayUnion([uid]),
        });
      }
    }
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
  // UPDATE FOOD
  // ==========================================================

  Future<String> updateFood(String foodId, Map<String, dynamic> data) async {
    try {
      if (foodId.isEmpty) {
        throw Exception("Food ID cannot be empty");
      }

      data.remove("updatedAt");

      await _firestore.collection("food_listings").doc(foodId).update({
        ...data,
        "updatedAt": Timestamp.now(),
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
  // SEND NOTIFICATION
  // ==========================================================

  Future<String> sendNotification({
    required String receiverId,
    required String senderId,
    required String reservationId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final notificationRef = _firestore.collection("notifications").doc();

      await notificationRef.set({
        "notificationId": notificationRef.id,
        "receiverId": receiverId,
        "senderId": senderId,
        "reservationId": reservationId,
        "title": title,
        "message": message,
        "type": type,
        "isRead": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // CUSTOMER NOTIFICATIONS
  // ==========================================================

  Stream<List<NotificationModel>> getCustomerNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection("notifications")
        .where("targetRole", isEqualTo: "receiver")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => NotificationModel.fromMap(doc.data(), docId: doc.id),
              )
              .toList();
        });
  }

  // ==========================================================
  // UNREAD COUNT
  // ==========================================================

  Stream<int> getUnreadNotificationCount(String role) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    var query = _firestore
        .collection("notifications")
        .where("targetRole", isEqualTo: role);

    if (role == 'provider') {
      query = query.where('targetUserId', isEqualTo: user.uid);
    }

    return query.snapshots().map((snapshot) {
      int unread = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final List<dynamic> readBy = data["readBy"] ?? [];

        if (!readBy.contains(user.uid)) {
          unread++;
        }
      }
      return unread;
    });
  }

  // ==========================================================
  // GET CUSTOMER ORDERS
  // ==========================================================

  Stream<List<ReservationModel>> getCustomerOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection("reservations")
        .where("customerId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data()))
              .toList();
        });
  }

  // ==========================================================
  // UPDATE RESERVATION STATUS
  // ==========================================================

  Future<String> updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    try {
      if (reservationId.isEmpty) return "Invalid ID";
      await _firestore.collection("reservations").doc(reservationId).update({
        "status": status,
        "updatedAt": Timestamp.now(),
      });
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // NOTIFY PROVIDER — NEW RESERVATION
  // ==========================================================
  Future<void> notifyProviderNewReservation({
    required String providerId,
    required String customerName,
    required String foodName,
    required String quantity,
  }) async {
    try {
      String message = quantity == "1"
          ? '$customerName reserved your "$foodName". 🍔'
          : '$customerName reserved $quantity of your "$foodName". 🍔';

      DocumentReference docRef = _firestore.collection('notifications').doc();

      await docRef.set({
        'notificationId': docRef.id,
        'title': 'New Reservation!',
        'message': message,
        'targetRole': 'provider',
        'targetUserId': providerId,
        'senderId': _auth.currentUser?.uid ?? '',
        'type': 'new_reservation',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': <String>[],
      });
    } catch (e) {
      print("Error creating provider notification: $e");
    }
  }

  // ==========================================================
  // RESERVE FOOD
  // ==========================================================
  Future<String> reserveFood({required FoodModel food}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Please login first";

      final customerDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .get();
      final customerData = customerDoc.data();

      DocumentReference reservationRef = _firestore
          .collection("reservations")
          .doc();
      double finalPrice = food.donation ? 0.0 : food.discountPrice;

      await reservationRef.set({
        "reservationId": reservationRef.id,
        "foodId": food.foodId,
        "customerId": user.uid,
        "customerName": customerData?["fullName"] ?? "Anonymous Customer",
        "providerId": food.providerId,
        "providerName": food.providerName,
        "foodName": food.foodName,
        "imageUrl": food.imageUrl,
        "quantity": 1,
        "price": finalPrice,
        "pickupDate": food.pickupDate,
        "pickupTime": food.pickupTime,
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await notifyProviderNewReservation(
        providerId: food.providerId,
        customerName: customerData?["fullName"] ?? "Anonymous Customer",
        foodName: food.foodName,
        quantity: "1",
      );

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // GET CUSTOMER RESERVATIONS
  // ==========================================================

  Stream<List<ReservationModel>> getCustomerReservations() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("reservations")
        .where("customerId", isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ==========================================================
  // CANCEL RESERVATION (UPDATED WITH STATUS & QUANTITY RESTORE)
  // ==========================================================
  Future<String> cancelReservation(String reservationId) async {
    try {
      DocumentSnapshot reservationDoc = await _firestore
          .collection("reservations")
          .doc(reservationId)
          .get();

      if (!reservationDoc.exists) return "Reservation not found";

      final data = reservationDoc.data() as Map<String, dynamic>;
      String foodId = data["foodId"] ?? "";
      int reservedQuantity = data["quantity"] ?? 1;
      String customerId = data["customerId"] ?? "";
      String foodName = data["foodName"] ?? "";

      DocumentReference foodRef = _firestore
          .collection("food_listings")
          .doc(foodId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot foodSnapshot = await transaction.get(foodRef);

        if (foodSnapshot.exists) {
          final foodData = foodSnapshot.data() as Map<String, dynamic>;
          int currentQuantity = foodData["quantity"] ?? 0;

          // 1. Food list me quantity wapas barha dein
          transaction.update(foodRef, {
            "quantity": currentQuantity + reservedQuantity,
          });
        }

        // 2. Document delete karne ki bajaye status "Cancelled" karein taake history kharab na ho
        transaction.update(
          _firestore.collection("reservations").doc(reservationId),
          {"status": "Cancelled", "updatedAt": Timestamp.now()},
        );
      });

      // 3. Customer ko notification bhejien ke order cancel ho gya hai
      if (customerId.isNotEmpty && foodName.isNotEmpty) {
        await notifyCustomerOrderStatus(
          customerId: customerId,
          foodName: foodName,
          status: "Cancelled",
        );
      }

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // GET PROVIDER RESERVATIONS (PRIORITY HIGHLIGHT FUNCTIONAL)
  // ==========================================================
  Stream<List<ReservationModel>> getProviderReservations({
    String? priorityReservationId,
  }) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection("reservations")
        .where("providerId", isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          try {
            List<ReservationModel> items = [];
            for (var doc in snapshot.docs) {
              final data = doc.data();
              data["reservationId"] = doc.id;
              items.add(ReservationModel.fromMap(data));
            }

            // High-End Intelligent Client Sorting
            items.sort((a, b) {
              // 1. Agar ye notification se khulne wala main card hai, to top priority do
              if (priorityReservationId != null &&
                  priorityReservationId.isNotEmpty) {
                if (a.reservationId == priorityReservationId) return -1;
                if (b.reservationId == priorityReservationId) return 1;
              }
              // 2. Default: Naye orders upar dikhao (Descending)
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt.compareTo(a.createdAt);
            });

            return items;
          } catch (e) {
            print("Error parsing reservations: $e");
            return [];
          }
        });
  }

  // ==========================================================
  // COMPLETE ORDER
  // ==========================================================

  Future<String> completeOrder(String reservationId) async {
    try {
      await _firestore.collection("reservations").doc(reservationId).update({
        "status": "Completed",
        "completedAt": Timestamp.now(),
      });
      return "success";
    } catch (e) {
      return "Error completing order: ${e.toString()}";
    }
  }

  // ==========================================================
  // CANCEL ORDER
  // ==========================================================

  Future<String> cancelOrder(String reservationId) async {
    try {
      await _firestore.collection("reservations").doc(reservationId).update({
        "status": "Cancelled",
        "cancelledAt": Timestamp.now(),
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
    if (currentUser == null) return Stream.value(0);
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
    if (currentUser == null) return Stream.value(0);
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
    if (currentUser == null) return Stream.value(0);
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
        message = 'Your order for "$foodName" has been accepted! ✅';
        break;
      case "Ready":
        message = '"$foodName" is ready for pickup! 🎉';
        break;
      case "Completed":
        message = 'Your order for "$foodName" is complete. Enjoy! 😊';
        break;
      case "Cancelled":
        message = 'Your order for "$foodName" was cancelled. ❌';
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

  // ==========================================================
  // MARK ALL NOTIFICATIONS AS READ
  // ==========================================================
  Future<void> markAllNotificationsAsRead(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;

    var query = _firestore
        .collection("notifications")
        .where("targetRole", isEqualTo: role);

    if (role == 'provider') {
      query = query.where('targetUserId', isEqualTo: user.uid);
    }

    final snapshot = await query.get();

    for (var doc in snapshot.docs) {
      List<dynamic> readBy = doc["readBy"] ?? [];
      if (!readBy.contains(user.uid)) {
        readBy.add(user.uid);
        await doc.reference.update({"readBy": readBy});
      }
    }
  }

  // ==========================================================
  // SAVED FOODS (WISHLIST MODULE)
  // ==========================================================
  Stream<bool> isFoodSaved(String foodId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection("saved_foods")
        .where("customerId", isEqualTo: user.uid)
        .where("foodId", isEqualTo: foodId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<String> toggleSavedFood({
    required String foodId,
    required bool isCurrentlySaved,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Please login first";

      final querySnapshot = await _firestore
          .collection("saved_foods")
          .where("customerId", isEqualTo: user.uid)
          .where("foodId", isEqualTo: foodId)
          .get();

      if (isCurrentlySaved && querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        return "Removed from Saved Items";
      } else if (!isCurrentlySaved && querySnapshot.docs.isEmpty) {
        await _firestore.collection("saved_foods").add({
          "customerId": user.uid,
          "foodId": foodId,
          "savedAt": FieldValue.serverTimestamp(),
        });
        return "Added to Saved Items";
      }
      return "No changes made";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Stream<List<FoodModel>> getSavedFood() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection("saved_foods")
        .where("customerId", isEqualTo: user.uid)
        .snapshots()
        .asyncMap((savedSnapshot) async {
          List<String> foodIds = savedSnapshot.docs
              .map((doc) => doc["foodId"] as String)
              .toList();

          if (foodIds.isEmpty) return <FoodModel>[];

          try {
            final foodsSnapshot = await _firestore
                .collection("food_listings")
                .where(FieldPath.documentId, whereIn: foodIds)
                .get();

            return foodsSnapshot.docs
                .map((doc) => FoodModel.fromMap(doc.data()))
                .toList();
          } catch (e) {
            print("Error fetching saved foods details: $e");
            return <FoodModel>[];
          }
        });
  }

  Stream<int> getSavedFoodCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection("saved_foods")
        .where("customerId", isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getOrdersCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection("reservations")
        .where("customerId", isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==========================================================
  // CLAIM DONATION
  // ==========================================================
  Future<void> claimDonation({
    required String foodId,
    required String providerId,
  }) async {
    String id = _firestore.collection("donation_claims").doc().id;

    await _firestore.collection("donation_claims").doc(id).set({
      "claimId": id,
      "foodId": foodId,
      "providerId": providerId,
      "receiverId": currentUser!.uid,
      "status": "Pending",
      "createdAt": Timestamp.now(),
    });

    await _firestore.collection("food_listings").doc(foodId).update({
      "status": "Claimed",
    });
  }
}
