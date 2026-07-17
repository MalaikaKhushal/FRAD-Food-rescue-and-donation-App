import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFoodDetails extends StatelessWidget {
  final DocumentSnapshot food;

  const ViewFoodDetails({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fb),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,

            pinned: true,

            elevation: 0,

            backgroundColor: Colors.orange,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),

              onPressed: () {
                Navigator.pop(context);
              },
            ),

            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: food.id,

                child: Image.network(
                  food["imageUrl"],

                  fit: BoxFit.cover,

                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade200,

                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          color: Colors.orange,
                          size: 90,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    food["foodName"],

                    style: const TextStyle(
                      fontSize: 30,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    food["category"],

                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),

                  const SizedBox(height: 25),

                  // ===== Price & Quantity Cards =====
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.10),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.payments_rounded,
                                color: Colors.green,
                                size: 30,
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Discount Price",
                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Rs ${food["discountPrice"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.10),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.orange,
                                size: 30,
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Available",
                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "${food["quantity"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ===== Description =====
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.10),

                          blurRadius: 12,

                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: Colors.orange,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          food["description"],

                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ===== Food Information =====
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.10),

                          blurRadius: 12,

                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        infoTile(
                          Icons.calendar_month,
                          "Pickup Date",
                          food["pickupDate"],
                        ),

                        const Divider(),

                        infoTile(
                          Icons.access_time,
                          "Pickup Time",
                          food["pickupTime"],
                        ),

                        const Divider(),

                        infoTile(Icons.timer, "Expiry", food["expiryTime"]),

                        const Divider(),

                        infoTile(
                          Icons.location_on,
                          "Location",
                          food["location"],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //==========================
                  // STATUS & DONATION
                  //==========================
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.10),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 30,
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Status",
                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                food["status"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.10),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.volunteer_activism,
                                color: food["donation"]
                                    ? Colors.green
                                    : Colors.grey,
                                size: 30,
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Donation",
                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                food["donation"] ? "YES" : "NO",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: food["donation"]
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  //==========================
                  // PROVIDER DETAILS
                  //==========================
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.10),

                          blurRadius: 12,

                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,

                          backgroundColor: Colors.orange.shade100,

                          child: const Icon(
                            Icons.store,

                            size: 35,

                            color: Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                food["providerName"],

                                style: const TextStyle(
                                  fontSize: 20,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                food["providerType"],

                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,

                    height: 55,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.arrow_back),

                      label: const Text(
                        "Back to Listings",

                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //========================================================
  // INFO TILE WIDGET
  //========================================================

  Widget infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.orange, size: 22),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
