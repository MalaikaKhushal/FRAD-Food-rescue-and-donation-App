import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frad/screens/food_detail_screen.dart';
import 'package:frad/screens/nearby_foods_screen.dart'; 
import 'dart:convert'; 

import '../models/food_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
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
          StreamBuilder<int>(
            stream: firestoreService.getUnreadNotificationCount(
              _auth.currentUser?.uid ?? '',
            ),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/notifications");
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minHeight: 18,
                          minWidth: 18,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? "9+" : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage:
                  currentUser?.imageUrl != null &&
                      currentUser!.imageUrl.isNotEmpty
                  ? Image.memory(
                      base64Decode(currentUser!.imageUrl.split(',').last),
                    ).image
                  : null,
              child:
                  currentUser?.imageUrl == null || currentUser!.imageUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xffF57C00))
                  : null,
            ),
            onSelected: (value) {
              if (value == "profile") {
                Navigator.pushNamed(
                  context,
                  "/profile",
                ).then((_) => loadUser()); 
              } else if (value == "logout") {
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
                value: "profile",
                child: Row(
                  children: [
                    Icon(Icons.account_circle_outlined, color: Colors.black87),
                    const SizedBox(width: 10),
                    Text("My Profile"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 10),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NearbyFoodsScreen()),
          );
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

  Widget _buildNormalView() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
              padding: const EdgeInsets.all(22),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Find Fresh Food Nearby",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Save Food • Save Money",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                hintText: "Search Food or City...", // ✅ UPDATED HINT
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
                itemBuilder: (context, index) => foodCard(food: foods[index]),
              );
            },
          ),
          const SizedBox(height: 25),
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
                itemBuilder: (context, index) =>
                    foodCard(food: donationFoods[index]),
              );
            },
          ),
          const SizedBox(height: 25),
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
              if (!snapshot.hasData) return const SizedBox();
              List<FoodModel> foods = snapshot.data!;
              foods = foods.where((food) {
                bool matchesCategory =
                    selectedCategory == "All" ||
                    food.providerType == selectedCategory;
                
                // ✅ UPDATED: Added location check here too
                bool matchesSearch = food.foodName.toLowerCase().contains(searchText) || 
                                     food.location.toLowerCase().contains(searchText);
                
                return matchesCategory && matchesSearch;
              }).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foods.length > 3 ? 3 : foods.length,
                itemBuilder: (context, index) => foodCard(food: foods[index]),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
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
              hintText: "Search Food or City...", // ✅ UPDATED HINT
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
              
              // ✅ FIXED: Filter now checks foodName, providerName, AND food.location
              List<FoodModel> searchResults = foods.where((food) {
                final nameMatch = food.foodName.toLowerCase().contains(searchText);
                final providerMatch = food.providerName.toLowerCase().contains(searchText);
                final locationMatch = food.location.toLowerCase().contains(searchText); 
                
                return nameMatch || providerMatch || locationMatch;
              }).toList();

              if (searchResults.isEmpty) return _buildNoResultsFound();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: searchResults.length,
                itemBuilder: (context, index) =>
                    foodCard(food: searchResults[index]),
              );
            },
          ),
        ),
      ],
    );
  }

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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
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

  Widget categoryCard(IconData icon, String title) {
    bool selected = selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = selected ? "All" : title;
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

  Widget foodCard({required FoodModel food}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
        );
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
                StreamBuilder<bool>(
                  stream: firestoreService.isFoodSaved(food.foodId),
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isSaved ? Colors.red : Colors.grey.shade400,
                      ),
                      onPressed: () async {
                        String message = await firestoreService.toggleSavedFood(
                          foodId: food.foodId,
                          isCurrentlySaved: isSaved,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
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
                  food.donation ? "Free Food" : "Rs ${food.discountPrice}",
                  style: TextStyle(
                    color: food.donation ? Colors.green : primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 10),
                if (!food.donation)
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
                    String result = await firestoreService.reserveFood(
                      food: food,
                    );

                    if (!mounted) return;

                    if (result == "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Reserved successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

  Widget navItem(IconData icon, String title, int index) {
    bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });

        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.pushNamed(context, "/savedFood").then((_) => loadUser());
            break;
          case 2:
            Navigator.pushNamed(context, "/orders").then((_) => loadUser());
            break;
          case 3:
            Navigator.pushNamed(context, "/profile").then((_) => loadUser());
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