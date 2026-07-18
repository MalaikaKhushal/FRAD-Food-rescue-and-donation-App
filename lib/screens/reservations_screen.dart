import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────
//  FRAD – Reservations Screen (Provider Side)
//  Fixed-height header (no collapse) — eliminates overflow.
// ─────────────────────────────────────────────────────────────
class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = "All";

  static const Color primary = Color(0xffE85D04);
  static const Color primaryDark = Color(0xffC44D02);
  static const Color bg = Color(0xffF6F7FB);

  final List<Map<String, dynamic>> tabs = [
    {"label": "All", "icon": Icons.grid_view_rounded},
    {"label": "Pending", "icon": Icons.hourglass_top_rounded},
    {"label": "Accepted", "icon": Icons.check_circle_outline_rounded},
    {"label": "Ready", "icon": Icons.inventory_2_outlined},
    {"label": "Completed", "icon": Icons.done_all_rounded},
    {"label": "Cancelled", "icon": Icons.cancel_outlined},
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return const Color(0xffF59E0B);
      case "Accepted":
        return const Color(0xff3B82F6);
      case "Ready":
        return const Color(0xff10B981);
      case "Completed":
        return const Color(0xff0D9488);
      case "Cancelled":
        return const Color(0xffEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Pending":
        return Icons.hourglass_top_rounded;
      case "Accepted":
        return Icons.check_circle_rounded;
      case "Ready":
        return Icons.inventory_2_rounded;
      case "Completed":
        return Icons.done_all_rounded;
      case "Cancelled":
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildStatusTabs(),
          Expanded(child: _buildReservationsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Reservations",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage incoming orders in real time",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Search by customer name...",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: primary, size: 22),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      color: bg,
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final tab = tabs[index];
            final bool selected = selectedStatus == tab["label"];

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => selectedStatus = tab["label"]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: selected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected ? primary : const Color(0xffE2E8F0),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab["icon"],
                        size: 16,
                        color: selected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab["label"],
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReservationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getProviderReservations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState();
        }

        List<DocumentSnapshot> reservations = snapshot.data!.docs;

        if (selectedStatus != "All") {
          reservations = reservations
              .where((doc) => doc["status"] == selectedStatus)
              .toList();
        }

        if (searchController.text.trim().isNotEmpty) {
          reservations = reservations.where((doc) {
            return doc["customerId"].toString().toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
          }).toList();
        }

        if (reservations.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          physics: const BouncingScrollPhysics(),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 250 + (index * 40)),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 16),
                  child: child,
                ),
              ),
              child: _buildReservationCard(reservations[index]),
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 46,
              color: primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "No reservations here",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "New orders will show up automatically",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(DocumentSnapshot reservation) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("food_listings")
          .doc(reservation["foodId"])
          .get(),
      builder: (context, foodSnapshot) {
        if (!foodSnapshot.hasData || !foodSnapshot.data!.exists) {
          return const SizedBox();
        }

        final food = foodSnapshot.data!.data() as Map<String, dynamic>;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(reservation["customerId"])
              .get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const SizedBox();
            }

            final user = userSnapshot.data!.data() as Map<String, dynamic>;
            final status = reservation["status"] as String;
            final color = _statusColor(status);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: reservation.id,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              food["imageUrl"] ?? '',
                              width: 78,
                              height: 78,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 78,
                                height: 78,
                                color: primary.withOpacity(0.08),
                                child: const Icon(
                                  Icons.fastfood_rounded,
                                  color: primary,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food["foodName"] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 9,
                                    backgroundColor: primary.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.person,
                                      size: 11,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      user["fullName"] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "${food["pickupDate"] ?? '-'} • ${food["pickupTime"] ?? '-'}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(status, color),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xffF1F1F1)),
                    const SizedBox(height: 12),
                    _buildActionRow(reservation, food, color, status),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    DocumentSnapshot reservation,
    Map<String, dynamic> food,
    Color color,
    String status,
  ) {
    Future<void> notify(String newStatus) async {
      await firestoreService.notifyCustomerOrderStatus(
        customerId: reservation["customerId"],
        foodName: food["foodName"] ?? '',
        status: newStatus,
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (status == "Pending")
          _actionButton(
            label: "Accept",
            icon: Icons.check_rounded,
            color: const Color(0xff10B981),
            filled: true,
            onTap: () async {
              await firestoreService.acceptReservation(reservation.id);
              await notify("Accepted");
            },
          ),
        if (status == "Accepted")
          _actionButton(
            label: "Mark Ready",
            icon: Icons.inventory_2_rounded,
            color: primary,
            filled: true,
            onTap: () async {
              await firestoreService.readyReservation(reservation.id);
              await notify("Ready");
            },
          ),
        if (status == "Ready")
          _actionButton(
            label: "Complete",
            icon: Icons.done_all_rounded,
            color: const Color(0xff0D9488),
            filled: true,
            onTap: () async {
              await firestoreService.completeOrder(reservation.id);
              await notify("Completed");
            },
          ),
        if (status != "Completed" && status != "Cancelled")
          _actionButton(
            label: "Cancel",
            icon: Icons.close_rounded,
            color: const Color(0xffEF4444),
            filled: false,
            onTap: () async {
              await firestoreService.cancelOrder(reservation.id);
              await notify("Cancelled");
            },
          ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool filled,
    required Future<void> Function() onTap,
  }) {
    return _AnimatedActionButton(
      label: label,
      icon: icon,
      color: color,
      filled: filled,
      onTap: onTap,
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final Future<void> Function() onTap;

  const _AnimatedActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _pressed = false;
  bool _loading = false;

  Future<void> _handleTap() async {
    setState(() => _loading = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _loading ? null : _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.filled ? widget.color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color, width: 1.4),
            boxShadow: widget.filled
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: _loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.filled ? Colors.white : widget.color,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.filled ? Colors.white : widget.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.filled ? Colors.white : widget.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
