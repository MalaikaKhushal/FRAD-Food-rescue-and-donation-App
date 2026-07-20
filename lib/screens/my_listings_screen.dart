import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frad/screens/view_food_details.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final TextEditingController searchController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  String searchText = "";
  String selectedStatus = "All";

  final List<String> statusList = [
    "All",
    "Active",
    "Reserved",
    "Expired",
    "Donated",
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int gridCount = 1;
    if (width >= 1400) {
      gridCount = 4;
    } else if (width >= 900) {
      gridCount = 3;
    } else if (width >= 650) {
      gridCount = 2;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "My Listings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          buildSearchBar(),
          const SizedBox(height: 12),
          buildFilter(),
          const SizedBox(height: 12),
          buildAnalytics(),
          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("food_listings")
                  .where("providerId", isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return buildEmptyState();
                }

                List<DocumentSnapshot> foodList = snapshot.data!.docs;

                // Client-side search filtering
                if (searchText.isNotEmpty) {
                  foodList = foodList.where((food) {
                    final foodName = (food["foodName"] ?? "")
                        .toString()
                        .toLowerCase();
                    return foodName.contains(searchText);
                  }).toList();
                }

                // Status filtering logic
                if (selectedStatus != "All") {
                  foodList = foodList.where((food) {
                    final data = food.data() as Map<String, dynamic>;
                    final status = (data["status"] ?? "")
                        .toString()
                        .toLowerCase();
                    final donation = data["donation"] == true;

                    switch (selectedStatus) {
                      case "Active":
                        return status == "available" || status == "active";
                      case "Reserved":
                        return status == "reserved";
                      case "Expired":
                        return status == "expired";
                      case "Donated":
                        return donation == true;
                      default:
                        return true;
                    }
                  }).toList();
                }

                if (foodList.isEmpty) {
                  return buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: foodList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent:
                        295, // Compact height: removes extra gaps & stops overflow
                  ),
                  itemBuilder: (context, index) {
                    var food = foodList[index];
                    var foodData = food.data() as Map<String, dynamic>;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Food Image & Badges
                            SizedBox(
                              height: 125,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      food["imageUrl"] ?? "",
                                      width: double.infinity,
                                      height: 125,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.fastfood,
                                              size: 40,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Status Badge
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        food["status"] ?? "Active",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Donation Tag
                                  if (foodData["donation"] == true)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          "DONATION",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Price Tag
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        foodData["donation"] == true
                                            ? "FREE"
                                            : "${food["discountPrice"] ?? 0} Rs",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Card Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food["foodName"] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      food["category"] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Colors.orange,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${food["quantity"] ?? 0} Left",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFFF7A00,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ViewFoodDetails(
                                                        food: food,
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              "View",
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFFFF7A00,
                                              ),
                                              side: const BorderSide(
                                                color: Color(0xFFFF7A00),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {
                                              _showFoodItemAnalytics(
                                                context,
                                                foodData,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.analytics_outlined,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              "Analytics",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fastfood, size: 60, color: Colors.orange),
          SizedBox(height: 12),
          Text(
            "No Food Found",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search Food",
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildFilter() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statusList.length,
        itemBuilder: (context, index) {
          bool selected = statusList[index] == selectedStatus;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(
                statusList[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
              ),
              selectedColor: Colors.orange,
              onSelected: (value) {
                setState(() {
                  selectedStatus = statusList[index];
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildAnalyticsHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("food_listings")
          .where("providerId", isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;
        int total = docs.length;
        int reserved = 0;
        int expired = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          String status = (data["status"] ?? "").toString().toLowerCase();

          if (status == "reserved" || status == "claimed") {
            reserved++;
          }
          if (status == "expired") {
            expired++;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: analyticsCard(
                  total.toString(),
                  "Listings",
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyticsCard(
                  reserved.toString(),
                  "Reserved",
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: analyticsCard(expired.toString(), "Expired", Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget analyticsCard(String value, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget buildAnalytics() {
    return buildAnalyticsHeader();
  }

  void _showFoodItemAnalytics(BuildContext context, Map<String, dynamic> food) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        int views = food["views"] ?? 0;
        int reservedCount =
            food["reservedCount"] ?? (food["status"] == "reserved" ? 1 : 0);
        double price = (food["discountPrice"] ?? 0).toDouble();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${food["foodName"] ?? "Food"} Analytics",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffF57C00),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text("Total Views"),
                trailing: Text(
                  "$views",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.bookmark_added, color: Colors.green),
                title: const Text("Reservations Count"),
                trailing: Text(
                  "$reservedCount",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.inventory, color: Colors.orange),
                title: const Text("Remaining Quantity"),
                trailing: Text(
                  "${food["quantity"] ?? 0}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.monetization_on,
                  color: Colors.purple,
                ),
                title: const Text("Potential Revenue"),
                trailing: Text(
                  "Rs ${price * (food["quantity"] ?? 1)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
