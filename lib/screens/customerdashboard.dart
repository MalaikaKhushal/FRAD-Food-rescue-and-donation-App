import 'package:flutter/material.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),

          const Padding(
            padding: EdgeInsets.only(right: 15),

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
              //------------------------------------
              // Header
              //------------------------------------
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
                        "Welcome 👋",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Find Fresh Food Nearby",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        "Save Food • Save Money",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------
              // Search Bar
              //------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search Food...",

                    prefixIcon: const Icon(Icons.search),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              //------------------------------------
              // Categories
              //------------------------------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Categories",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 105,

                child: ListView(
                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  children: [
                    categoryCard(Icons.restaurant, "Restaurant"),

                    categoryCard(Icons.cake, "Bakery"),

                    categoryCard(Icons.rice_bowl, "Hostel"),

                    categoryCard(Icons.celebration, "Catering"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //------------------------------------
              // Nearby Food
              //------------------------------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Nearby Food",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              foodCard(
                foodName: "Chicken Burger",
                provider: "Al Baik Restaurant",
                price: "Rs.250",
                originalPrice: "Rs.600",
                pickupTime: "Pickup Before 10:00 PM",
                isDonation: false,
              ),

              foodCard(
                foodName: "Chocolate Cake",
                provider: "Fresh Bakers",
                price: "FREE",
                originalPrice: "Donation",
                pickupTime: "Pickup Before 09:00 PM",
                isDonation: true,
              ),

              foodCard(
                foodName: "Chicken Biryani",
                provider: "COMSATS Hostel Mess",
                price: "Rs.180",
                originalPrice: "Rs.350",
                pickupTime: "Pickup Before 08:30 PM",
                isDonation: false,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          // Food Map / Scan Feature
        },
        child: const Icon(Icons.location_on, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: SizedBox(
          height: 65,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              navItem(Icons.home, "Home", 0),

              navItem(Icons.favorite, "Saved", 1),

              const SizedBox(width: 40),

              navItem(Icons.shopping_bag, "Orders", 2),

              navItem(Icons.person, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  //---------------------------------------------------
  // CATEGORY CARD
  //---------------------------------------------------

  Widget categoryCard(IconData icon, String title) {
    return Container(
      width: 90,

      margin: const EdgeInsets.only(right: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          CircleAvatar(
            radius: 22,

            backgroundColor: primaryColor.withOpacity(.15),

            child: Icon(icon, color: primaryColor),
          ),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  //---------------------------------------------------
  // FOOD CARD
  //---------------------------------------------------

  Widget foodCard({
    required String foodName,
    required String provider,
    required String price,
    required String originalPrice,
    required String pickupTime,
    required bool isDonation,
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

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 75,
                height: 75,

                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.12),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(Icons.fastfood, size: 40, color: primaryColor),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      foodName,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(provider),

                    const SizedBox(height: 5),

                    Text(
                      pickupTime,

                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              if (isDonation)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    "FREE",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Text(
                price,

                style: TextStyle(
                  color: primaryColor,

                  fontWeight: FontWeight.bold,

                  fontSize: 20,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                originalPrice,

                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () {
                  // Food Details Screen
                },

                child: const Text(
                  "Reserve",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  //---------------------------------------------------
  // Bottom Navigation Item
  //---------------------------------------------------

  Widget navItem(IconData icon, String title, int index) {
    bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });

        switch (index) {
          case 0:
            // Home
            break;

          case 1:
            // Saved Food Screen
            break;

          case 2:
            // My Reservations Screen
            break;

          case 3:
            // Customer Profile Screen
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
