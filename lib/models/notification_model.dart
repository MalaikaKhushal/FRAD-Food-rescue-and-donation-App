import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId; // Added this field
  final String title;
  final String message;
  final String targetRole;
  final String targetUserId;
  final Timestamp createdAt;
  final List<dynamic> readBy;

  NotificationModel({
    required this.notificationId, // Added here
    required this.title,
    required this.message,
    required this.targetRole,
    required this.targetUserId,
    required this.createdAt,
    required this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      "notificationId": notificationId,
      "title": title,
      "message": message,
      "targetRole": targetRole,
      "targetUserId": targetUserId,
      "createdAt": createdAt,
      "readBy": readBy,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return NotificationModel(
      // Agar map me id nahi hai toh snapshot se pass ki hui docId use hogi
      notificationId: map["notificationId"] ?? docId ?? "",
      title: map["title"] ?? "",
      message: map["message"] ?? "",
      targetRole: map["targetRole"] ?? "",
      targetUserId: map["targetUserId"] ?? "",
      createdAt: map["createdAt"] ?? Timestamp.now(),
      readBy: List<dynamic>.from(map["readBy"] ?? []),
    );
  }
}
