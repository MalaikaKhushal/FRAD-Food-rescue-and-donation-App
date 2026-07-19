import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({super.key});

  @override
  State<ProviderAnalyticsScreen> createState() =>
      _ProviderAnalyticsScreenState();
}

class _ProviderAnalyticsScreenState extends State<ProviderAnalyticsScreen> {
  final FirestoreService firestoreService = FirestoreService();

  static const Color primary = Color(0xffF57C00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: primary,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Business Analytics",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Business Overview",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.05,

              children: [
                dashboardCard(
                  title: "Food Listings",

                  icon: Icons.fastfood,

                  color: Colors.orange,

                  stream: firestoreService.getTotalListings(),
                ),

                dashboardCard(
                  title: "Orders",

                  icon: Icons.shopping_bag,

                  color: Colors.green,

                  stream: firestoreService.getTotalReservations(),
                ),

                dashboardCard(
                  title: "Donations",

                  icon: Icons.favorite,

                  color: Colors.red,

                  stream: firestoreService.getTotalDonations(),
                ),

                dashboardCard(
                  title: "Revenue",

                  icon: Icons.currency_rupee,

                  color: Colors.blue,

                  stream: firestoreService.getTotalRevenue(),

                  isMoney: true,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Order Statistics",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 3,

              crossAxisSpacing: 12,

              mainAxisSpacing: 12,

              childAspectRatio: .95,

              children: [
                dashboardCard(
                  title: "Pending",

                  icon: Icons.pending_actions,

                  color: Colors.orange,

                  stream: firestoreService.getPendingOrders(),
                ),

                dashboardCard(
                  title: "Completed",

                  icon: Icons.check_circle,

                  color: Colors.green,

                  stream: firestoreService.getCompletedOrders(),
                ),

                dashboardCard(
                  title: "Cancelled",

                  icon: Icons.cancel,

                  color: Colors.red,

                  stream: firestoreService.getCancelledOrders(),
                ),
              ],
            ),

            const SizedBox(height: 30),
            StreamBuilder(
              stream: firestoreService.getPendingOrders(),
              builder: (context, pendingSnap) {
                int pending = pendingSnap.data ?? 0;

                return StreamBuilder(
                  stream: firestoreService.getCompletedOrders(),
                  builder: (context, completedSnap) {
                    int completed = completedSnap.data ?? 0;

                    return StreamBuilder(
                      stream: firestoreService.getCancelledOrders(),
                      builder: (context, cancelledSnap) {
                        int cancelled = cancelledSnap.data ?? 0;

                        return buildPieChart(
                          pending: pending,
                          completed: completed,
                          cancelled: cancelled,
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),

                    blurRadius: 8,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Business Summary",

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Your business performance is updated automatically from Firebase.",

                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.analytics, color: primary),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "All listings, donations and completed orders contribute to your analytics.",

                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildPieChart({
    required int pending,
    required int completed,
    required int cancelled,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Distribution",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 45,
                sectionsSpace: 4,
                sections: [
                  PieChartSectionData(
                    value: pending.toDouble(),
                    color: Colors.orange,
                    radius: 55,
                    title: "$pending",
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: completed.toDouble(),
                    color: Colors.green,
                    radius: 55,
                    title: "$completed",
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  PieChartSectionData(
                    value: cancelled.toDouble(),
                    color: Colors.red,
                    radius: 55,
                    title: "$cancelled",
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              legend(Colors.orange, "Pending"),

              legend(Colors.green, "Completed"),

              legend(Colors.red, "Cancelled"),
            ],
          ),
        ],
      ),
    );
  }

  Widget legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream stream,
    bool isMoney = false,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        String value = "0";

        if (snapshot.hasData) {
          if (isMoney) {
            value = "Rs ${(snapshot.data as double).toStringAsFixed(0)}";
          } else {
            value = snapshot.data.toString();
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withOpacity(.12),
                  child: Icon(icon, color: color, size: 28),
                ),

                const SizedBox(height: 14),

                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
