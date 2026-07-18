import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await firestoreService.markAllNotificationsAsRead();
    });
  }

  final FirestoreService firestoreService = FirestoreService();

  final Color primaryColor = const Color(0xffF57C00);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: primaryColor,

        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getCustomerNotifications(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Notifications Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: width * .04,
              vertical: 18,
            ),

            itemCount: notifications.length,

            itemBuilder: (context, index) {
              final notification = notifications[index];

              return notificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget notificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: primaryColor.withOpacity(.12),
          child: Icon(Icons.notifications_active_rounded, color: primaryColor),
        ),

        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: const TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 10),

              Text(
                notification.createdAt.toDate().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        trailing: notification.readBy.isEmpty
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
            : const Icon(Icons.done_all, color: Colors.green),
      ),
    );
  }
}
