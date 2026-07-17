import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/notification_bell.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int currentIndex = 0;
  String selectedCategory = "All";
  String searchText = "";
  final FirestoreService firestoreService = FirestoreService();

  UserModel? currentUser;

  final Color primaryColor = const Color(0xffF57C00);
  Future<void> loadUser() async {
    currentUser = await firestoreService.getCurrentUserData();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    loadUser();
  }

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
          NotificationBell(role: 'receiver'),

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

                child: Padding(
                  padding: EdgeInsets.all(22),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        currentUser == null
                            ? "Loading..."
                            : "Good Evening,\n${currentUser!.fullName}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
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
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase();
                    });
                  },

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

              StreamBuilder<List<FoodModel>>(
                stream: firestoreService.getAllFood(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No Food Available",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }

                  List<FoodModel> foods = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      FoodModel food = foods[index];

                      return foodCard(food: food);
                    },
                  );
                },
              ),
              const SizedBox(height: 25),

              //------------------------------------
              // Donation Food
              //------------------------------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Donation Food",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              StreamBuilder<List<FoodModel>>(
                stream: firestoreService.getDonationFood(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No Donation Food Available"),
                    );
                  }

                  List<FoodModel> donationFoods = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: donationFoods.length,
                    itemBuilder: (context, index) {
                      return foodCard(food: donationFoods[index]);
                    },
                  );
                },
              ),

              const SizedBox(height: 25),

              //------------------------------------
              // Recommended
              //------------------------------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recommended For You",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              StreamBuilder<List<FoodModel>>(
                stream: firestoreService.getAllFood(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  List<FoodModel> foods = snapshot.data!;

                  foods = foods.where((food) {
                    bool matchesCategory =
                        selectedCategory == "All" ||
                        food.providerType == selectedCategory;

                    bool matchesSearch = food.foodName.toLowerCase().contains(
                      searchText,
                    );

                    return matchesCategory && matchesSearch;
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foods.length > 3 ? 3 : foods.length,
                    itemBuilder: (context, index) {
                      return foodCard(food: foods[index]);
                    },
                  );
                },
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
    bool selected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 12),

        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(.15), blurRadius: 10),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: selected ? Colors.white : primaryColor),

            const SizedBox(height: 8),

            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //---------------------------------------------------
  // FOOD CARD
  //---------------------------------------------------

  Widget foodCard({required FoodModel food}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/foodDetails", arguments: food);
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        padding: const EdgeInsets.all(16),

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
          children: [
            Row(
              children: [
                Container(
                  width: 75,
                  height: 75,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(food.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        food.foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(food.providerName),

                      const SizedBox(height: 5),

                      Text(
                        food.pickupTime,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                if (food.donation)
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

            const SizedBox(height: 15),

            Row(
              children: [
                Text(
                  "Rs ${food.discountPrice}",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "Rs ${food.originalPrice}",
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),

                  onPressed: () async {
                    await firestoreService.reserveFood(
                      foodId: food.foodId,
                      providerId: food.providerId,
                    );

                    if (!mounted) return;

                    Navigator.pushNamed(context, "/reservation");
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
