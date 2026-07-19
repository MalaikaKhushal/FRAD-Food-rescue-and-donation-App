import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final Color primaryColor = const Color(0xffF57C00);
  String userRole = 'receiver'; // Default safe role

  @override
  void initState() {
    super.initState();
    _determineRoleAndMarkRead();
  }

  Future<void> _determineRoleAndMarkRead() async {
    try {
      UserModel user = await firestoreService.getCurrentUserData();
      if (mounted) {
        setState(() {
          userRole = user.role.toLowerCase() == 'provider'
              ? 'provider'
              : 'receiver';
        });
        await firestoreService.markAllNotificationsAsRead(userRole);
      }
    } catch (e) {
      print("Error loading user role for notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getNotificationsForRole(userRole),
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
          // Sorting locally to prevent Firestore Index requirement errors
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isRead = notification.readBy.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          // 1. Notification ko read mark karein taake gayab na ho balki save rahe
          await firestoreService.markNotificationRead(
            notification.notificationId,
          );

          if (!mounted) return;

          // 2. Role ke mutabik sahi screens par bhejein
          if (userRole == 'provider') {
            Navigator.pushNamed(context, "/providerReservations");
          } else {
            Navigator.pushNamed(
              context,
              "/customerOrders",
            ); // Apni customer screen route dalyein agar alag hai
          }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: isRead
                ? Colors.grey.shade200
                : primaryColor.withOpacity(.12),
            child: Icon(
              Icons.notifications_active_rounded,
              color: isRead ? Colors.grey : primaryColor,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 16,
              color: isRead ? Colors.black54 : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: TextStyle(
                    color: isRead ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  notification.createdAt.toDate().toString().substring(0, 16),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing: !isRead
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : const Icon(Icons.done_all, color: Colors.green, size: 20),
        ),
      ),
    );
  }
}
