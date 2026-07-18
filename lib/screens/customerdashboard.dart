import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/notification_bell.dart';
import 'loginscreen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int currentIndex = 0;
  String selectedCategory = "All";
  String searchText = "";
  bool isSearching = false;
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();

  UserModel? currentUser;

  final Color primaryColor = const Color(0xffF57C00);

  Future<void> loadUser() async {
    currentUser = await firestoreService.getCurrentUserData();

    if (mounted) {
      setState(() {});
    }
  }

  // ✅ Logout Function
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
  void initState() {
    super.initState();
    loadUser();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                      currentUser?.fullName ?? "User",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(currentUser?.role ?? "Customer"),
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

          const SizedBox(width: 5),
        ],
      ),

      body: SafeArea(
        child: isSearching && searchText.isNotEmpty
            ? _buildSearchResults()
            : _buildNormalView(),
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

  //------------------------------------
  // NORMAL VIEW (جب search نہیں ہو رہا)
  //------------------------------------
  Widget _buildNormalView() {
    return SingleChildScrollView(
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
              controller: searchController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    isSearching = true;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "Search Food...",

                prefixIcon: const Icon(Icons.search),

                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = "";
                            isSearching = false;
                          });
                        },
                      )
                    : null,

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
    );
  }

  //------------------------------------
  // SEARCH RESULTS VIEW
  //------------------------------------
  Widget _buildSearchResults() {
    return Column(
      children: [
        //------------------------------------
        // Search Bar (top)
        //------------------------------------
        Container(
          color: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: TextField(
            controller: searchController,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  isSearching = true;
                });
              }
            },
            decoration: InputDecoration(
              hintText: "Search Food...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchText = "";
                    isSearching = false;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        //------------------------------------
        // Search Results
        //------------------------------------
        Expanded(
          child: StreamBuilder<List<FoodModel>>(
            stream: firestoreService.getAllFood(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildNoResultsFound();
              }

              List<FoodModel> foods = snapshot.data!;

              // Filter based on search text
              List<FoodModel> searchResults = foods.where((food) {
                return food.foodName.toLowerCase().contains(searchText) ||
                    food.providerName.toLowerCase().contains(searchText);
              }).toList();

              if (searchResults.isEmpty) {
                return _buildNoResultsFound();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return foodCard(food: searchResults[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  //------------------------------------
  // No Results Found Widget
  //------------------------------------
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Result Not Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No food matching '$searchText' available",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              searchController.clear();
              setState(() {
                searchText = "";
                isSearching = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Clear Search",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
