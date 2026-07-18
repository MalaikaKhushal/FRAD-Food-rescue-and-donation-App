import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String reservationId;
  final String foodId;

  final String customerId;
  final String customerName;

  final String providerId;
  final String providerName;

  final String foodName;
  final String imageUrl;

  final int quantity;
  final double price;

  final String pickupDate;
  final String pickupTime;

  final String status;

  final Timestamp createdAt;

  ReservationModel({
    required this.reservationId,
    required this.foodId,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.foodName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.pickupDate,
    required this.pickupTime,
    required this.status,
    required this.createdAt,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      reservationId: map["reservationId"] ?? "",
      foodId: map["foodId"] ?? "",

      customerId: map["customerId"] ?? "",
      customerName: map["customerName"] ?? "",

      providerId: map["providerId"] ?? "",
      providerName: map["providerName"] ?? "",

      foodName: map["foodName"] ?? "",
      imageUrl: map["imageUrl"] ?? "",

      quantity: map["quantity"] ?? 0,

      price: (map["price"] ?? 0).toDouble(),

      pickupDate: map["pickupDate"] ?? "",
      pickupTime: map["pickupTime"] ?? "",

      status: map["status"] ?? "Pending",

      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}
