import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String foodId;
  final String providerId;
  final String providerName;
  final String providerType;

  final String foodName;
  final String description;
  final String category;

  final int quantity;

  final double originalPrice;
  final double discountPrice;

  final bool donation;

  final String pickupDate;
  final String pickupTime;
  final String expiryTime;

  final String location;

  final String imageUrl;

  final String status;

  final Timestamp createdAt;

  FoodModel({
    required this.foodId,
    required this.providerId,
    required this.providerName,
    required this.providerType,
    required this.foodName,
    required this.description,
    required this.category,
    required this.quantity,
    required this.originalPrice,
    required this.discountPrice,
    required this.donation,
    required this.pickupDate,
    required this.pickupTime,
    required this.expiryTime,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "foodId": foodId,
      "providerId": providerId,
      "providerName": providerName,
      "providerType": providerType,
      "foodName": foodName,
      "description": description,
      "category": category,
      "quantity": quantity,
      "originalPrice": originalPrice,
      "discountPrice": discountPrice,
      "donation": donation,
      "pickupDate": pickupDate,
      "pickupTime": pickupTime,
      "expiryTime": expiryTime,
      "location": location,
      "imageUrl": imageUrl,
      "status": status,
      "createdAt": createdAt,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      foodId: map["foodId"] ?? "",
      providerId: map["providerId"] ?? "",
      providerName: map["providerName"] ?? "",
      providerType: map["providerType"] ?? "",
      foodName: map["foodName"] ?? "",
      description: map["description"] ?? "",
      category: map["category"] ?? "",
      quantity: map["quantity"] ?? 0,
      originalPrice: (map["originalPrice"] ?? 0).toDouble(),
      discountPrice: (map["discountPrice"] ?? 0).toDouble(),
      donation: map["donation"] ?? false,
      pickupDate: map["pickupDate"] ?? "",
      pickupTime: map["pickupTime"] ?? "",
      expiryTime: map["expiryTime"] ?? "",
      location: map["location"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      status: map["status"] ?? "",
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }

  Object? get id => foodId;
}
