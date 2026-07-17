class ProviderModel {
  final String id;
  final String businessName;
  final String category;
  final String email;
  final String phone;
  final String address;
  final String imageUrl;
  final double rating;
  final bool verified;

  ProviderModel({
    required this.id,
    required this.businessName,
    required this.category,
    required this.email,
    required this.phone,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.verified,
  });

  factory ProviderModel.fromMap(Map<String, dynamic> data, String id) {
    return ProviderModel(
      id: id,
      businessName: data['businessName'] ?? '',
      category: data['category'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      verified: data['verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'category': category,
      'email': email,
      'phone': phone,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'verified': verified,
    };
  }
}
