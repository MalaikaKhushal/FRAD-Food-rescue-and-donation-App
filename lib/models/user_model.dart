import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  // ✅ Profile screen ke liye missing fields add kar di hain
  final String? address;
  final dynamic createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.address,
    this.createdAt,
  });

  // ✅ Profile screen 'imageUrl' dhund rahi hai, toh humne getter bana diya taake purana 'profileImage' bhi kaam kare aur error bhi na aaye
  String get imageUrl => profileImage ?? '';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'address': address,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      profileImage:
          map['profileImage'] ??
          map['imageUrl'], // Dono names ko handle kar lega safely
      address: map['address'] ?? 'Not Provided',
      createdAt: map['createdAt'],
    );
  }
}
