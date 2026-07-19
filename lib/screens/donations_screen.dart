import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'view_food_details.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final TextEditingController searchController = TextEditingController();

  static const Color primary = Color(0xffE85D04);
  static const Color primaryDark = Color(0xffC44D02);
  static const Color background = Color(0xffF8F9FA);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          _header(),

          _topBar(),

          Expanded(child: _foodStream()),
        ],
      ),
    );
  }

  //==========================================================
  // HEADER
  //==========================================================

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 16),

                        SizedBox(width: 6),

                        Text(
                          "Donation",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                "Free Food Donation",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Collect surplus food shared by providers",
                style: TextStyle(color: Colors.white.withOpacity(.9)),
              ),

              const SizedBox(height: 22),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "Search food...",
                    prefixIcon: const Icon(Icons.search, color: primary),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==========================================================
  // TOP BAR
  //==========================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Row(
        children: [
          const Text(
            "Available Donations",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "FREE",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //==========================================================
  // FIRESTORE STREAM
  //==========================================================

  Widget _foodStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("food_listings")
          .orderBy("createdAt", descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState();
        }

        List<DocumentSnapshot> foods = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return data["donation"] == true && data["status"] == "Available";
        }).toList();

        if (searchController.text.isNotEmpty) {
          foods = foods.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return data["foodName"].toString().toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
          }).toList();
        }

        if (foods.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: foods.length,

          itemBuilder: (context, index) {
            final food = foods[index];

            final data = food.data() as Map<String, dynamic>;
            final String foodName = data["foodName"] ?? "Unnamed Food";

            final String description = data["description"] ?? "";

            final String provider = data["providerName"] ?? "";

            final String location = data["location"] ?? "";

            final String quantity = "${data["quantity"] ?? 0}";

            final String image = data["imageUrl"] ?? "";

            final String status = data["status"] ?? "Available";

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => ViewFoodDetails(food: food),
                    ),
                  );
                },

                child: Card(
                  elevation: 3,

                  shadowColor: Colors.black12,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(14),

                    child: Row(
                      children: [
                        Hero(
                          tag: data["foodId"],

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),

                            child: image.isNotEmpty
                                ? Image.network(
                                    image,

                                    width: 95,

                                    height: 95,

                                    fit: BoxFit.cover,

                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        width: 95,

                                        height: 95,

                                        color: Colors.grey.shade200,

                                        child: const Icon(
                                          Icons.fastfood,

                                          color: primary,

                                          size: 40,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 95,

                                    height: 95,

                                    color: Colors.grey.shade200,

                                    child: const Icon(
                                      Icons.fastfood,

                                      color: primary,

                                      size: 40,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,

                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(.15),

                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    child: const Text(
                                      "FREE",

                                      style: TextStyle(
                                        color: Colors.green,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,

                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      color: status == "Available"
                                          ? Colors.orange.withOpacity(.15)
                                          : Colors.red.withOpacity(.15),

                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    child: Text(
                                      status,

                                      style: TextStyle(
                                        color: status == "Available"
                                            ? Colors.orange
                                            : Colors.red,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                foodName,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                description,

                                maxLines: 2,

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  color: Colors.grey.shade700,

                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,

                                    size: 16,

                                    color: primary,
                                  ),

                                  const SizedBox(width: 4),

                                  Expanded(
                                    child: Text(
                                      provider,

                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,

                                    size: 16,

                                    color: Colors.red,
                                  ),

                                  const SizedBox(width: 4),

                                  Expanded(
                                    child: Text(
                                      location,

                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.inventory,

                                    size: 16,

                                    color: Colors.orange,
                                  ),

                                  const SizedBox(width: 4),

                                  Text(
                                    "$quantity Items",

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const Spacer(),

                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,

                                    size: 16,

                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: primary,
                size: 60,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "No Donations Available",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "There are currently no free food donations available.\nPlease check again later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
