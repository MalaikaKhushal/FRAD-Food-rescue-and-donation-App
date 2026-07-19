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
      reservationId: map["reservationId"]?.toString() ?? "",
      foodId: map["foodId"]?.toString() ?? "",
      customerId: map["customerId"]?.toString() ?? "",
      customerName: map["customerName"]?.toString() ?? "",
      providerId: map["providerId"]?.toString() ?? "",
      providerName: map["providerName"]?.toString() ?? "",
      foodName: map["foodName"]?.toString() ?? "",
      imageUrl: map["imageUrl"]?.toString() ?? "",
      quantity: int.tryParse(map["quantity"]?.toString() ?? "0") ?? 0,
      price: double.tryParse(map["price"]?.toString() ?? "0.0") ?? 0.0,
      pickupDate: map["pickupDate"]?.toString() ?? "",
      pickupTime: map["pickupTime"]?.toString() ?? "",
      status: map["status"]?.toString() ?? "Pending",
      createdAt: map["createdAt"] is Timestamp
          ? map["createdAt"]
          : Timestamp.now(),
    );
  }
}
