import 'package:flutter/material.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int currentIndex = 0;

  final Color primaryColor = const Color(0xffF57C00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,

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
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(right: 16),

            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xffF57C00)),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //--------------------------------------------------
              // Header
              //--------------------------------------------------
              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: primaryColor,

                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: const Padding(
                  padding: EdgeInsets.all(22),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Welcome Back 👋",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Restaurant Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        "Reduce Food Waste • Help Communities",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Statistics Heading
              //--------------------------------------------------
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

              //--------------------------------------------------
              // Statistics Cards
              //--------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),

                  shrinkWrap: true,

                  crossAxisCount: 2,

                  crossAxisSpacing: 14,

                  mainAxisSpacing: 14,

                  childAspectRatio: 1.25,

                  children: [
                    dashboardCard(
                      Icons.fastfood,
                      "12",
                      "Food Listings",
                      Colors.orange,
                    ),

                    dashboardCard(
                      Icons.shopping_bag,
                      "08",
                      "Reservations",
                      Colors.green,
                    ),

                    dashboardCard(
                      Icons.favorite,
                      "04",
                      "Donations",
                      Colors.red,
                    ),

                    dashboardCard(
                      Icons.payments,
                      "Rs. 6,500",
                      "Today's Earnings",
                      Colors.blue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Quick Actions
              //--------------------------------------------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Quick Actions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: GridView.count(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,

                  crossAxisSpacing: 14,

                  mainAxisSpacing: 14,

                  childAspectRatio: 1.10,

                  children: [
                    actionCard(Icons.add_box_rounded, "Add Extra Food"),

                    actionCard(Icons.inventory, "My Listings"),

                    actionCard(Icons.receipt_long, "Reservations"),

                    actionCard(Icons.volunteer_activism, "Donations"),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              //--------------------------------------------------
              // Recent Listings
              //--------------------------------------------------
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

              const SizedBox(height: 15),

              foodCard(
                image: Icons.lunch_dining,
                title: "Chicken Burger",
                quantity: "5 Available",
                price: "Rs.250",
                pickup: "Before 10:00 PM",
              ),

              foodCard(
                image: Icons.bakery_dining,
                title: "Chocolate Cake",
                quantity: "2 Available",
                price: "Rs.600",
                pickup: "Before 09:00 PM",
              ),

              foodCard(
                image: Icons.rice_bowl,
                title: "Chicken Biryani",
                quantity: "8 Available",
                price: "Rs.180",
                pickup: "Before 08:30 PM",
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      //--------------------------------------------------
      // Floating Button
      //--------------------------------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 6,
        onPressed: () {
          // Add Food Screen
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      //--------------------------------------------------
      // Bottom Navigation
      //--------------------------------------------------
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: SizedBox(
          height: 65,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              navItem(Icons.home, "Home", 0),

              navItem(Icons.fastfood, "My Food", 1),

              const SizedBox(width: 40),

              navItem(Icons.receipt_long, "Orders", 2),

              navItem(Icons.person, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Dashboard Card
  //--------------------------------------------------

  Widget dashboardCard(IconData icon, String value, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.15),

            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // Quick Action Card
  //--------------------------------------------------

  Widget actionCard(IconData icon, String title) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {},

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryColor.withOpacity(.15),

              child: Icon(icon, color: primaryColor, size: 28),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Food Card
  //--------------------------------------------------

  Widget foodCard({
    required IconData image,
    required String title,
    required String quantity,
    required String price,
    required String pickup,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: primaryColor.withOpacity(.15),

            child: Icon(image, size: 35, color: primaryColor),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(quantity),

                Text(price),

                Text(pickup),
              ],
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {},
            child: const Text("View", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  } //--------------------------------------------------
  // Bottom Navigation Item
  //--------------------------------------------------

  Widget navItem(IconData icon, String title, int index) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          currentIndex = index;
        });

        switch (index) {
          case 0:
            // Home
            break;

          case 1:
            // My Listings Screen
            break;

          case 2:
            // Orders Screen
            break;

          case 3:
            // Profile Screen
            break;
        }
      },

      child: SizedBox(
        width: 70,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
