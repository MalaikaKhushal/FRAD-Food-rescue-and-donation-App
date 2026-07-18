import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String title;
  final String message;

  final String targetRole;
  final String targetUserId;

  final Timestamp createdAt;

  final List<dynamic> readBy;

  NotificationModel({
    required this.title,
    required this.message,
    required this.targetRole,
    required this.targetUserId,
    required this.createdAt,
    required this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "message": message,
      "targetRole": targetRole,
      "targetUserId": targetUserId,
      "createdAt": createdAt,
      "readBy": readBy,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map["title"] ?? "",
      message: map["message"] ?? "",
      targetRole: map["targetRole"] ?? "",
      targetUserId: map["targetUserId"] ?? "",
      createdAt: map["createdAt"] ?? Timestamp.now(),
      readBy: List<dynamic>.from(map["readBy"] ?? []),
    );
  }
}
