import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'loginscreen.dart';

class ProviderDashboard extends StatefulWidget {
  final String name;
  final String role;

  const ProviderDashboard({super.key, required this.name, required this.role});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final Color primaryColor = const Color(0xffF57C00);

  int currentIndex = 0;

  int? hoveredDashboard;
  int? hoveredAction;
  int? hoveredFood;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> stats = [
    {
      "icon": Icons.fastfood,
      "title": "Food Listings",
      "value": "12",
      "color": Colors.orange,
    },

    {
      "icon": Icons.shopping_bag,
      "title": "Orders",
      "value": "08",
      "color": Colors.green,
    },

    {
      "icon": Icons.favorite,
      "title": "Donations",
      "value": "24",
      "color": Colors.red,
    },

    {
      "icon": Icons.star,
      "title": "Rating",
      "value": "4.9",
      "color": Colors.blue,
    },
  ];

  final List<Map<String, dynamic>> actions = [
    {"icon": Icons.add_box_rounded, "title": "Add Food"},

    {"icon": Icons.inventory_2_outlined, "title": "My Listings"},

    {"icon": Icons.receipt_long, "title": "Reservations"},

    {"icon": Icons.volunteer_activism, "title": "Donations"},
  ];

  final List<Map<String, dynamic>> foods = [
    {
      "icon": Icons.lunch_dining,
      "title": "Chicken Burger",
      "qty": "5 Available",
      "price": "Rs.250",
      "time": "Before 10:00 PM",
    },

    {
      "icon": Icons.bakery_dining,
      "title": "Chocolate Cake",
      "qty": "2 Available",
      "price": "Rs.600",
      "time": "Before 09:00 PM",
    },

    {
      "icon": Icons.rice_bowl,
      "title": "Chicken Biryani",
      "qty": "8 Available",
      "price": "Rs.180",
      "time": "Before 08:30 PM",
    },
  ];

  bool get isDesktop =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  Future<void> logout() async {
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
          IconButton(
            onPressed: () {},

            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),

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
                      widget.name,
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
                        widget.role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Reduce Food Waste • Help Communities",
                      style: TextStyle(color: Colors.white, fontSize: 15),
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

                child: GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: stats.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 16,

                    mainAxisSpacing: 16,

                    childAspectRatio: 1.15,
                  ),

                  itemBuilder: (context, index) {
                    return dashboardCard(index, stats[index]);
                  },
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

                    childAspectRatio: 1.45,
                  ),

                  itemBuilder: (context, index) {
                    return actionCard(index, actions[index]);
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// ===========================
              /// RECENT FOOD LISTINGS
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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  return foodCard(index, foods[index]);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      /// ===========================
      /// FLOATING ACTION BUTTON
      /// ===========================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 6,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add Food screen coming soon")),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Food",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      /// ===========================
      /// BOTTOM NAVIGATION
      /// ===========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          switch (index) {
            case 0:
              // Dashboard
              break;

            case 1:
              // Foods
              break;

            case 2:
              // Orders
              break;

            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile screen coming soon")),
              );
              break;
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

  Widget dashboardCard(int index, Map<String, dynamic> item) {
    final hovered = hoveredDashboard == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredDashboard = index),
      onExit: (_) => setState(() => hoveredDashboard = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: hovered
            ? (Matrix4.identity()..translate(0, -5))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: hovered ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: item["color"].withOpacity(.12),
                child: Icon(item["icon"], color: item["color"], size: 26),
              ),
              Text(
                item["value"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item["title"],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("${item["title"]} clicked")));
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

  Widget foodCard(int index, Map<String, dynamic> item) {
    final hovered = hoveredFood == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredFood = index),
      onExit: (_) => setState(() => hoveredFood = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        transform: hovered
            ? (Matrix4.identity()..translate(0, -4))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: hovered ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor.withOpacity(.12),
            child: Icon(item["icon"], color: primaryColor),
          ),
          title: Text(
            item["title"],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["qty"]),
                const SizedBox(height: 4),
                Text(item["time"]),
              ],
            ),
          ),
          trailing: Text(
            item["price"],
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
