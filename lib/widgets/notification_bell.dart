import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationBell extends StatefulWidget {
  final String role; // 'provider' or 'receiver'
  const NotificationBell({super.key, required this.role});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('targetRole', isEqualTo: widget.role)
          .where('targetUserId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final unreadCount = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final readBy = List<String>.from(data['readBy'] ?? []);
          return !readBy.contains(_uid);
        }).length;

        if (unreadCount > 0) {
          _shakeController.forward(from: 0);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => _showNotificationSheet(context, docs),
              icon: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final angle = (unreadCount > 0)
                      ? 0.15 *
                            (1 - _shakeController.value) *
                            ((_shakeController.value * 10).floor() % 2 == 0
                                ? 1
                                : -1)
                      : 0.0;
                  return Transform.rotate(angle: angle, child: child);
                },
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationSheet(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Notifications",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: docs.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text("No notifications yet"),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final readBy = List<String>.from(
                              data['readBy'] ?? [],
                            );
                            final isUnread = !readBy.contains(_uid);
                            final type = data['type'] ?? '';

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 200 + (index * 40),
                              ),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 12),
                                  child: child,
                                ),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  // 1. First mark as read in Firestore
                                  await FirebaseFirestore.instance
                                      .collection('notifications')
                                      .doc(docs[index].id)
                                      .update({
                                        'readBy': FieldValue.arrayUnion([_uid]),
                                      });

                                  // 2. Close the bottom sheet
                                  if (!context.mounted) return;
                                  Navigator.pop(context);

                                  // 3. If provider notification type is 'new_reservation', route to reservations
                                  if (widget.role == 'provider' &&
                                      type == 'new_reservation') {
                                    Navigator.pushNamed(
                                      context,
                                      "/providerReservations",
                                    );
                                  }
                                  // Optional: If customer notification, route to customer orders/reservations screen
                                  else if (widget.role == 'receiver') {
                                    Navigator.pushNamed(
                                      context,
                                      "/customerOrders",
                                    );
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: isUnread
                                      ? Colors.orange.withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.12),
                                  child: Icon(
                                    Icons.fastfood_rounded,
                                    color: isUnread
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  data['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(data['message'] ?? ''),
                                trailing: isUnread
                                    ? Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
