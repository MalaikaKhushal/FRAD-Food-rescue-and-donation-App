import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final String? address;
  // ✅ FIXED: City field add ki taake Nearby Foods screen par error khatam ho jaye
  final String? city;
  final dynamic createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.address,
    this.city, // ✅ Included in constructor
    this.createdAt,
  });

  // Profile screen 'imageUrl' dhund rahi hai, toh humne getter bana diya taake purana 'profileImage' bhi kaam kare aur error bhi na aaye
  String get imageUrl => profileImage ?? '';

  // ✅ Getter for City so it never returns null and safely gives empty string if not found
  String get cityValue => city ?? '';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'address': address,
      'city': city, // ✅ Map me add kiya
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
      city:
          map['city'] ??
          '', // ✅ Firestore se city value read karne ke liye logic add kiya
      createdAt: map['createdAt'],
    );
  }
}
