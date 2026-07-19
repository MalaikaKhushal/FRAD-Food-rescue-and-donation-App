import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';
import '../services/firestore_service.dart';

class ViewFoodDetails extends StatefulWidget {
  final dynamic food;

  const ViewFoodDetails({Key? key, required this.food}) : super(key: key);

  @override
  State<ViewFoodDetails> createState() => _ViewFoodDetailsState();
}

class _ViewFoodDetailsState extends State<ViewFoodDetails> {
  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;

  late String foodId;
  late String providerId;

  String foodName = "";
  String providerName = "";
  String category = "";
  String description = "";
  String location = "";
  String quantity = "";
  String imageUrl = "";
  String heroTag = "";
  String status = "";
  bool donation = false;

  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  void _loadFood() {
    if (widget.food is DocumentSnapshot) {
      final doc = widget.food as DocumentSnapshot;

      final data = doc.data() as Map<String, dynamic>;

      foodId = data["foodId"] ?? doc.id;
      providerId = data["providerId"] ?? "";

      heroTag = doc.id;

      foodName = data["foodName"] ?? "";
      providerName = data["providerName"] ?? "";
      category = data["category"] ?? "";
      description = data["description"] ?? "";
      quantity = "${data["quantity"] ?? 0}";
      location = data["location"] ?? "";
      imageUrl = data["imageUrl"] ?? "";
      status = data["status"] ?? "";
      donation = data["donation"] ?? false;
    } else if (widget.food is FoodModel) {
      final FoodModel model = widget.food;

      foodId = model.foodId;
      providerId = model.providerId;

      heroTag = model.foodId;

      foodName = model.foodName;
      providerName = model.providerName;
      category = model.category;
      description = model.description;
      quantity = model.quantity.toString();
      location = model.location;
      imageUrl = model.imageUrl;
      status = model.status;
      donation = model.donation;
    }
  }

  Future<void> _claimDonation() async {
    try {
      setState(() {
        isLoading = true;
      });

      await firestoreService.claimDonation(
        foodId: foodId,
        providerId: providerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Donation request sent successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _imageSection() {
    return Hero(
      tag: heroTag,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: double.infinity,
              height: 330,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _placeholderImage();
              },
            )
          : _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 330,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood, color: Colors.orange, size: 90),
    );
  }

  Widget infoCard(IconData icon, Color color, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.orange,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(background: _imageSection()),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// FOOD NAME
                      Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// CATEGORY
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          infoCard(
                            Icons.inventory_2_outlined,
                            Colors.orange,
                            "Quantity",
                            quantity,
                          ),

                          const SizedBox(width: 15),

                          infoCard(
                            donation ? Icons.volunteer_activism : Icons.sell,
                            donation ? Colors.green : Colors.blue,
                            donation ? "Price" : "Discount",
                            donation ? "FREE" : "Rs 0",
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.person, color: Colors.white),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Provider",
                                    style: TextStyle(color: Colors.grey),
                                  ),

                                  Text(
                                    providerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              description,
                              style: const TextStyle(fontSize: 16, height: 1.6),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _claimDonation,
                icon: const Icon(Icons.volunteer_activism),
                label: Text(isLoading ? "Sending..." : "Claim Donation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
