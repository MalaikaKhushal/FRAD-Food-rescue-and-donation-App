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
            fontSize: 25,
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
          const SizedBox(height: 15),
          buildSearchBar(),
          const SizedBox(height: 15),
          buildFilter(),
          const SizedBox(height: 15),
          buildAnalyticsHeader(),
          const SizedBox(height: 15),
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

                    // Date-based expiry check safeguard
                    bool isExpiredByDate = false;
                    if (data.containsKey("expiryDate") &&
                        data["expiryDate"] != null) {
                      DateTime? expDate;
                      if (data["expiryDate"] is Timestamp) {
                        expDate = (data["expiryDate"] as Timestamp).toDate();
                      } else if (data["expiryDate"] is String) {
                        expDate = DateTime.tryParse(data["expiryDate"]);
                      }
                      if (expDate != null && expDate.isBefore(DateTime.now())) {
                        isExpiredByDate = true;
                      }
                    }

                    switch (selectedStatus) {
                      case "Active":
                        return (status == "available" ||
                                status == "active" ||
                                status == "pending") &&
                            !isExpiredByDate;
                      case "Reserved":
                        return status == "reserved" || status == "claimed";
                      case "Expired":
                        return status == "expired" || isExpiredByDate;
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
                  padding: const EdgeInsets.all(16),
                  itemCount: foodList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent:
                        380, // Explicit height prevents gaps & overflows
                  ),
                  itemBuilder: (context, index) {
                    var food = foodList[index];
                    var foodData = food.data() as Map<String, dynamic>;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewFoodDetails(food: food),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Food Image Stack Section
                            SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      foodData["imageUrl"] ?? "",
                                      width: double.infinity,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.fastfood,
                                              size: 45,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Status Badge
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        (foodData["status"] ?? "Available")
                                            .toString()
                                            .toUpperCase(),
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
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          "DONATION",
                                          style: TextStyle(
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

                            // 2. Details Compact Section (Gap Removed)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          foodData["foodName"] ??
                                              "Untitled Food",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          foodData["category"] ?? "Other",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${foodData["quantity"] ?? 0} Left",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Text(
                                      foodData["donation"] == true
                                          ? "FREE"
                                          : "Rs ${foodData["discountPrice"] ?? 0}",
                                      style: TextStyle(
                                        color: foodData["donation"] == true
                                            ? Colors.green
                                            : const Color(0xffF57C00),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    // Action Buttons Row
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
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                              size: 16,
                                            ),
                                            label: const Text(
                                              "View",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                              size: 16,
                                            ),
                                            label: const Text(
                                              "Analytics",
                                              style: TextStyle(fontSize: 12),
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

  // Search Bar Widget
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search Food",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Chips Filter Header Widget
  Widget buildFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selectedColor: Colors.orange,
              backgroundColor: Colors.white,
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

  // Analytics Dashboard Header Widget
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

          // Expiry date verification logic
          bool isExpiredByDate = false;
          if (data.containsKey("expiryDate") && data["expiryDate"] != null) {
            DateTime? expDate;
            if (data["expiryDate"] is Timestamp) {
              expDate = (data["expiryDate"] as Timestamp).toDate();
            } else if (data["expiryDate"] is String) {
              expDate = DateTime.tryParse(data["expiryDate"]);
            }
            if (expDate != null && expDate.isBefore(DateTime.now())) {
              isExpiredByDate = true;
            }
          }

          if (status == "reserved" || status == "claimed") {
            reserved++;
          }
          if (status == "expired" || isExpiredByDate) {
            expired++;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: analyticsCard(
                  total.toString(),
                  "Listings",
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: analyticsCard(
                  reserved.toString(),
                  "Reserved",
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Individual Food Item Analytics Popup Dialog
  void _showFoodItemAnalytics(BuildContext context, Map<String, dynamic> food) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        int views = food["views"] ?? 0;
        int reservedCount =
            food["reservedCount"] ?? (food["status"] == "reserved" ? 1 : 0);
        double price = (food["discountPrice"] ?? 0).toDouble();

        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${food["foodName"]} Analytics",
                    style: const TextStyle(
                      fontSize: 20,
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
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text("Total Views"),
                trailing: Text(
                  "$views",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_added, color: Colors.green),
                title: const Text("Reservations Count"),
                trailing: Text(
                  "$reservedCount",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.inventory, color: Colors.orange),
                title: const Text("Remaining Quantity"),
                trailing: Text(
                  "${food["quantity"] ?? 0}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.monetization_on,
                  color: Colors.purple,
                ),
                title: const Text("Potential Revenue"),
                trailing: Text(
                  "Rs ${price * (food["quantity"] ?? 1)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
