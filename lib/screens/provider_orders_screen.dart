import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen> {
  final FirestoreService firestoreService = FirestoreService();

  int selectedTab = 0;

  final List<String> tabs = [
    "Pending",

    "Accepted",

    "Ready",

    "Completed",

    "Cancelled",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.orange,

        centerTitle: true,

        title: const Text(
          "Food Orders",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          SizedBox(
            height: 45,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,

              itemCount: tabs.length,

              itemBuilder: (context, index) {
                bool selected = selectedTab == index;

                return Padding(
                  padding: const EdgeInsets.only(left: 12),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),

                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,

                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: selected ? Colors.orange : Colors.white,

                        borderRadius: BorderRadius.circular(30),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.15),

                            blurRadius: 8,
                          ),
                        ],
                      ),

                      child: Text(
                        tabs[index],

                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getProviderOrders(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Orders Yet",

                      style: TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                List<DocumentSnapshot> orders = snapshot.data!.docs;

                orders = orders.where((doc) {
                  return doc["status"] == tabs[selectedTab];
                }).toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      "No ${tabs[selectedTab]} Orders",

                      style: const TextStyle(fontSize: 17),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),

                  itemCount: orders.length,

                  itemBuilder: (context, index) {
                    DocumentSnapshot order = orders[index];
                    Map<String, dynamic> data =
                        order.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.12),

                            blurRadius: 10,

                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),

                                  child: Image.network(
                                    data["imageUrl"],

                                    width: 70,

                                    height: 70,

                                    fit: BoxFit.cover,

                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        width: 70,

                                        height: 70,

                                        color: Colors.grey.shade200,

                                        child: const Icon(
                                          Icons.fastfood,

                                          size: 35,

                                          color: Colors.orange,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        data["foodName"],

                                        style: const TextStyle(
                                          fontSize: 18,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        "Customer : ${data["customerName"]}",
                                      ),

                                      const SizedBox(height: 3),

                                      Text("Qty : ${data["quantity"]}"),

                                      const SizedBox(height: 3),

                                      Text("Pickup : ${data["pickupDate"]}"),

                                      const SizedBox(height: 3),

                                      Text(data["pickupTime"]),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,

                                  children: [
                                    Text(
                                      "Rs ${data["price"]}",

                                      style: const TextStyle(
                                        color: Colors.orange,

                                        fontWeight: FontWeight.bold,

                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,

                                        vertical: 6,
                                      ),

                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(.15),

                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        data["status"],

                                        style: const TextStyle(
                                          color: Colors.orange,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                if (data["status"] == "Pending")
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,

                                        foregroundColor: Colors.white,
                                      ),

                                      onPressed: () async {
                                        await firestoreService
                                            .updateReservationStatus(
                                              order.id,

                                              "Accepted",
                                            );
                                      },

                                      child: const Text("Accept"),
                                    ),
                                  ),

                                if (data["status"] == "Pending")
                                  const SizedBox(width: 10),

                                if (data["status"] == "Pending")
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,

                                        foregroundColor: Colors.white,
                                      ),

                                      onPressed: () async {
                                        await firestoreService
                                            .updateReservationStatus(
                                              order.id,

                                              "Cancelled",
                                            );
                                      },

                                      child: const Text("Reject"),
                                    ),
                                  ),

                                if (data["status"] == "Accepted")
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,

                                        foregroundColor: Colors.white,
                                      ),

                                      onPressed: () async {
                                        await firestoreService
                                            .updateReservationStatus(
                                              order.id,

                                              "Ready",
                                            );
                                      },

                                      child: const Text("Mark Ready"),
                                    ),
                                  ),

                                if (data["status"] == "Ready")
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,

                                        foregroundColor: Colors.white,
                                      ),

                                      onPressed: () async {
                                        await firestoreService
                                            .updateReservationStatus(
                                              order.id,

                                              "Completed",
                                            );
                                      },

                                      child: const Text("Complete"),
                                    ),
                                  ),
                              ],
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
}
