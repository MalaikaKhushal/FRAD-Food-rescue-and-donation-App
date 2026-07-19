import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../services/firestore_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final Color primaryColor = const Color(0xffF57C00);

  // Track loading index to show loader on the specific card being cancelled
  String deletingReservationId = "";

  // Functional Cancel Logic Function
  Future<void> _handleCancelOrder(String reservationId) async {
    // Show confirmation dialog before deleting
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Cancel Order",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Are you sure you want to cancel this food reservation?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Yes, Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      deletingReservationId = reservationId;
    });

    try {
      // Calling Firestore to delete/cancel reservation
      await firestoreService.cancelReservation(reservationId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Order cancelled successfully!"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to cancel order: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          deletingReservationId = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: firestoreService.getCustomerOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("🔴 FIRESTORE ERROR: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Something went wrong",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Orders Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return orderCard(orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget orderCard(ReservationModel order) {
    Color statusColor = Colors.orange;
    String currentStatus = order.status.trim().toLowerCase();

    switch (currentStatus) {
      case "accepted":
        statusColor = Colors.green;
        break;
      case "rejected":
        statusColor = Colors.red;
        break;
      case "completed":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    bool isCurrentlyDeleting = deletingReservationId == order.reservationId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool mobile = constraints.maxWidth < 600;

            return mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            order.imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.fastfood, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        order.foodName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Provider : ${order.providerName}"),
                      Text("Quantity : ${order.quantity}"),
                      Text("Pickup : ${order.pickupDate}"),
                      Text(order.pickupTime),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Rs ${order.price.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (currentStatus == "pending")
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: isCurrentlyDeleting
                                ? null
                                : () => _handleCancelOrder(order.reservationId),
                            icon: isCurrentlyDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete),
                            label: Text(
                              isCurrentlyDeleting
                                  ? "Cancelling..."
                                  : "Cancel Order",
                            ),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          order.imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.fastfood),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.foodName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text("Provider : ${order.providerName}"),
                            Text("Quantity : ${order.quantity}"),
                            Text(
                              "Pickup : ${order.pickupDate} ${order.pickupTime}",
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Rs ${order.price.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (currentStatus == "pending")
                            ElevatedButton(
                              onPressed: isCurrentlyDeleting
                                  ? null
                                  : () =>
                                        _handleCancelOrder(order.reservationId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: isCurrentlyDeleting
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Cancel"),
                            ),
                        ],
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
