import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frad/screens/view_food_details.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final TextEditingController searchController = TextEditingController();

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
          const SizedBox(height: 20),

          buildSearchBar(),

          const SizedBox(height: 20),

          buildFilter(),

          const SizedBox(height: 20),

          buildAnalytics(),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("food_listings")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (snapshot.data == null) {
                  return const Center(child: Text("No Data"));
                }

                List<DocumentSnapshot> foodList = snapshot.data!.docs;

                if (searchText.isNotEmpty) {
                  foodList = foodList.where((food) {
                    return food["foodName"].toString().toLowerCase().contains(
                      searchText,
                    );
                  }).toList();
                }

                if (selectedStatus != "All") {
                  foodList = foodList.where((food) {
                    final status = (food["status"] ?? "")
                        .toString()
                        .toLowerCase();
                    final donation = food["donation"] == true;

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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: const [
                        Icon(Icons.fastfood, size: 70, color: Colors.orange),

                        SizedBox(height: 15),

                        Text(
                          "No Food Found",

                          style: TextStyle(
                            fontSize: 20,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),

                  itemCount: foodList.length,

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,

                    crossAxisSpacing: 20,

                    mainAxisSpacing: 20,

                    childAspectRatio: .74,
                  ),

                  itemBuilder: (context, index) {
                    var food = foodList[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          // Food Details Screen yahan open hogi
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (food["donation"] == true)
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
                                    borderRadius: BorderRadius.circular(30),
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
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  "${food["discountPrice"]} Rs",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Food Image
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(22),
                                    ),
                                    child: Image.network(
                                      food["imageUrl"],
                                      width: double.infinity,
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
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        food["status"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      food["foodName"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      food["category"],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const Spacer(),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.inventory_2,
                                          color: Colors.orange,
                                          size: 18,
                                        ),

                                        const SizedBox(width: 5),

                                        Text("${food["quantity"]} Left"),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Rs ${food["discountPrice"]}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

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
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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

                                              // Food Details Screen yahan open hogi
                                            },
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 18,
                                            ),
                                            label: const Text("View"),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

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
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              // Analytics Screen yahan open hogi
                                            },
                                            icon: const Icon(
                                              Icons.analytics_outlined,
                                              size: 18,
                                            ),
                                            label: const Text("Analytics"),
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

          prefixIcon: const Icon(Icons.search),

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildFilter() {
    return SizedBox(
      height: 45,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 20),

        itemCount: statusList.length,

        itemBuilder: (context, index) {
          bool selected = statusList[index] == selectedStatus;

          return Padding(
            padding: const EdgeInsets.only(right: 10),

            child: ChoiceChip(
              selected: selected,

              label: Text(statusList[index]),

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

  Widget buildAnalytics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("food_listings")
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

          if (status == "reserved") {
            reserved++;
          }

          if (status == "expired") {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            value,

            style: TextStyle(
              fontSize: 28,

              color: color,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(title),
        ],
      ),
    );
  }
}
