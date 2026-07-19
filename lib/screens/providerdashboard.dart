import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frad/screens/add_food_screen.dart';
import 'package:frad/screens/my_listings_screen.dart';

import 'loginscreen.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../models/food_model.dart';
import '../widgets/notification_bell.dart';

class ProviderDashboard extends StatefulWidget {
  final String name;
  final String role;

  const ProviderDashboard({super.key, required this.name, required this.role});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  final FirestoreService firestoreService = FirestoreService();
  UserModel? currentUser;
  final Color primaryColor = const Color(0xffF57C00);
  int currentIndex = 0;

  int? hoveredDashboard;
  int? hoveredAction;
  int? hoveredFood;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> actions = [
    {"icon": Icons.add_box_rounded, "title": "Add Food"},
    {"icon": Icons.inventory_2_outlined, "title": "My Listings"},
    {"icon": Icons.receipt_long, "title": "Orders"},

    {"icon": Icons.qr_code_2_rounded, "title": "Payment QR"},
    {"icon": Icons.analytics, "title": "Analytics"},
    {"icon": Icons.volunteer_activism, "title": "Donations"},
  ];

  bool get isDesktop =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  Future<void> loadUser() async {
    currentUser = await firestoreService.getCurrentUserData();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> logout() async {
    final bool? confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              title: const Text(
                "Logout",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;
    await _auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "FRAD",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          NotificationBell(role: 'provider'),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xffF57C00)),
            ),
            onSelected: (value) {
              if (value == "logout") {
                logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.role),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            children: [
              /// ===========================
              /// HEADER
              /// ===========================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser == null
                          ? "Loading..."
                          : currentUser!.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentUser == null ? "" : currentUser!.role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              /// ===========================
              /// TODAY OVERVIEW
              /// ===========================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Today's Overview",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    firebaseDashboardCard(
                      title: "Food Listings",
                      icon: Icons.fastfood,
                      color: Colors.orange,
                      stream: firestoreService.getTotalListings(),
                    ),
                    firebaseDashboardCard(
                      title: "Orders",
                      icon: Icons.shopping_bag,
                      color: Colors.green,
                      stream: firestoreService.getTotalReservations(),
                    ),
                    firebaseDashboardCard(
                      title: "Donations",
                      icon: Icons.favorite,
                      color: Colors.red,
                      stream: firestoreService.getTotalDonations(),
                    ),
                    firebaseDashboardCard(
                      title: "Rating",
                      icon: Icons.star,
                      color: Colors.blue,
                      stream: Stream.value(5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              /// ===========================
              /// QUICK ACTIONS
              /// ===========================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: actions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    return actionCard(index, actions[index]);
                  },
                ),
              ),
              const SizedBox(height: 30),

              /// ===========================
              /// RECENT FOOD LISTINGS (FIXED LISVIEW RENDERING)
              /// ===========================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recent Food Listings",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              StreamBuilder<List<FoodModel>>(
                stream: firestoreService.getProviderFood(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Error loading listings: ${snapshot.error}",
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No Food Listings Yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  List<FoodModel> foods = snapshot.data!;

                  // ✅ FIXED: Separated from outer scroll logic using explicit builders
                  return ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const ClampingScrollPhysics(), // Allows clean integration inside SingleChildScrollView
                    itemCount: foods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      return foodCard(foods[index]);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 6,
        onPressed: () {
          Navigator.pushNamed(context, "/addFood");
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Food",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 1) {
            Navigator.pushNamed(context, "/myListings");
          }

          if (index == 2) {
            Navigator.pushNamed(context, "/providerReservations");
          }

          if (index == 3) {
            Navigator.pushNamed(context, "/providerProfile");
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Foods"),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget firebaseDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<int> stream,
  }) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        String value = "0";
        if (snapshot.hasData) {
          value = snapshot.data.toString();
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withOpacity(.12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget actionCard(int index, Map<String, dynamic> item) {
    final hovered = hoveredAction == index;
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredAction = index),
      onExit: (_) => setState(() => hoveredAction = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: hovered
            ? (Matrix4.identity()..translate(0, -6))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: hovered ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            switch (item["title"]) {
              case "Analytics":
                Navigator.pushNamed(context, "/analytics");
                break;
              case "Add Food":
                Navigator.pushNamed(context, "/addFood");
                break;
              case "My Listings":
                Navigator.pushNamed(context, "/myListings");
                break;
              case "Reservations":
                Navigator.pushNamed(context, "/providerReservations");
                break;
              case "Orders":
                Navigator.pushNamed(context, "/providerOrders");
                break;
              case "Donations":
                Navigator.pushNamed(context, "/donations");
                break;
              case "Payment QR":
                Navigator.pushNamed(context, "/providerQr");
                break;
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item["icon"],
                size: 34,
                color: hovered ? Colors.white : primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                item["title"],
                style: TextStyle(
                  color: hovered ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget foodCard(FoodModel food) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              food.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fastfood, color: primaryColor),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.foodName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "${food.quantity} Available",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                Text(
                  "Pickup: ${food.pickupTime}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                Text(
                  food.location,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rs ${food.discountPrice}",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/editFood",
                        arguments: food,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.edit, color: Colors.orange),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      showDeleteDialog(food);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.delete, color: Colors.red, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteDialog(FoodModel food) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Food"),
          content: Text("Delete ${food.foodName} ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                String result = await firestoreService.deleteFood(food.foodId);
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result)));
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
