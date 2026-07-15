import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodModel? food;
  const AddFoodScreen({super.key, this.food});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
  
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String imageUrl = "";

  @override
  void initState() {
    super.initState();

    if (widget.food != null) {
      foodNameController.text = widget.food!.foodName;
      descriptionController.text = widget.food!.description;
      selectedCategory = widget.food!.category;
      quantityController.text = widget.food!.quantity.toString();
      originalPriceController.text = widget.food!.originalPrice.toString();
      discountPriceController.text = widget.food!.discountPrice.toString();
      donation = widget.food!.donation;
      pickupDateController.text = widget.food!.pickupDate;
      pickupTimeController.text = widget.food!.pickupTime;
      expiryTimeController.text = widget.food!.expiryTime;
      locationController.text = widget.food!.location;
      imageUrlController.text = widget.food!.imageUrl;
    }
  }

  //==================================================
  // SAVE FOOD TO FIRESTORE
  //==================================================

  Future<void> saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = await firestoreService.getCurrentUserData();

      String foodId = FirebaseFirestore.instance
          .collection("food_listings")
          .doc()
          .id;

      FoodModel food = FoodModel(
        foodId: foodId,
        providerId: currentUser.uid,
        providerName: currentUser.fullName,
        providerType: currentUser.role,
        foodName: foodNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory,
        quantity: int.parse(quantityController.text.trim()),
        originalPrice: double.parse(originalPriceController.text.trim()),
        discountPrice: double.parse(discountPriceController.text.trim()),
        donation: donation,
        pickupDate: pickupDateController.text.trim(),
        pickupTime: pickupTimeController.text.trim(),
        expiryTime: expiryTimeController.text.trim(),
        location: locationController.text.trim(),
        imageUrl: imageUrlController.text.trim(),
        status: "Available",
        createdAt: Timestamp.now(),
      );

      String result;

      if (widget.food == null) {
        // ADD NEW FOOD
        result = await firestoreService.addFood(food);
      } else {
        // UPDATE EXISTING FOOD
        result = await firestoreService.updateFood(
          foodId: widget.food!.foodId,
          foodName: foodNameController.text.trim(),
          quantity: int.parse(quantityController.text.trim()),
          discountPrice: double.parse(discountPriceController.text.trim()),
          location: locationController.text.trim(),
          pickupTime: pickupTimeController.text.trim(),
          imageUrl: imageUrlController.text.trim(),
          donation: donation,
        );
      }

      if (result == "success") {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              widget.food == null
                  ? "Food Added Successfully"
                  : "Food Updated Successfully",
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        throw Exception(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  final FirestoreService firestoreService = FirestoreService();

  final FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = const Color(0xffF57C00);

  bool isLoading = false;

  bool donation = false;

  //=============================
  // Controllers
  //=============================

  final TextEditingController foodNameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  

  final TextEditingController originalPriceController = TextEditingController();

  final TextEditingController discountPriceController = TextEditingController();

  final TextEditingController pickupDateController = TextEditingController();

  final TextEditingController pickupTimeController = TextEditingController();

  final TextEditingController expiryTimeController = TextEditingController();

  

  final TextEditingController imageUrlController = TextEditingController();

  String selectedCategory = "Fast Food";

  final List<String> categories = [
    "Fast Food",

    "Bakery",

    "Rice",

    "Dessert",

    "Beverages",

    "Pizza",

    "Burger",

    "Other",
  ];

  @override
  void dispose() {
    foodNameController.dispose();

    descriptionController.dispose();

    quantityController.dispose();

    originalPriceController.dispose();

    discountPriceController.dispose();

    pickupDateController.dispose();

    pickupTimeController.dispose();

    expiryTimeController.dispose();

    locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: primaryColor,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Add Food",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

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
                      const Icon(
                        Icons.fastfood,

                        size: 70,

                        color: Color(0xffF57C00),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Add New Food Listing",

                        style: TextStyle(
                          fontSize: 22,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Fill all details below",

                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 25),

                      // Food Name
                      TextFormField(
                        controller: foodNameController,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Food Name";
                          }

                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Food Name",

                          prefixIcon: const Icon(Icons.restaurant),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        controller: descriptionController,

                        maxLines: 3,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Description";
                          }

                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Description",

                          prefixIcon: const Icon(Icons.description),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Category
                      DropdownButtonFormField(
                        value: selectedCategory,

                        decoration: InputDecoration(
                          labelText: "Category",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        items: categories.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Quantity
                      //=============================
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Quantity";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Available Quantity",
                          prefixIcon: const Icon(Icons.numbers),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Original Price
                      //=============================
                      TextFormField(
                        controller: originalPriceController,
                        keyboardType: TextInputType.number,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Original Price";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Original Price",

                          prefixIcon: const Icon(Icons.currency_rupee),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Discount Price
                      //=============================
                      TextFormField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,

                        validator: (value) {
                          if (!donation && (value == null || value.isEmpty)) {
                            return "Enter Discount Price";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Discount Price",

                          prefixIcon: const Icon(Icons.local_offer),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Donation Switch
                      //=============================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,

                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              color: Color(0xffF57C00),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Text(
                                "Donate this food for FREE",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),

                            Switch(
                              value: donation,

                              activeColor: primaryColor,

                              onChanged: (value) {
                                setState(() {
                                  donation = value;

                                  if (donation) {
                                    discountPriceController.text = "0";
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Divider(),

                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pickup Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Pickup Date
                      //=============================
                      TextFormField(
                        controller: pickupDateController,
                        readOnly: true,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select Pickup Date";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Pickup Date",

                          prefixIcon: const Icon(Icons.calendar_today),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );

                          if (pickedDate != null) {
                            pickupDateController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Pickup Time
                      //=============================
                      TextFormField(
                        controller: pickupTimeController,
                        readOnly: true,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select Pickup Time";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Pickup Time",

                          prefixIcon: const Icon(Icons.access_time),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            pickupTimeController.text = pickedTime.format(
                              context,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Expiry Time
                      //=============================
                      TextFormField(
                        controller: expiryTimeController,
                        readOnly: true,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select Expiry Time";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Expiry Time",

                          prefixIcon: const Icon(Icons.timer_off),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            expiryTimeController.text = pickedTime.format(
                              context,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Location
                      //=============================
                      TextFormField(
                        controller: locationController,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Pickup Location";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Pickup Location",

                          prefixIcon: const Icon(Icons.location_on),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //=============================
                      // Image URL
                      //=============================
                      TextFormField(
                        controller: imageUrlController,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter image URL";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          labelText: "Food Image URL",

                          hintText: "https://images.unsplash.com/.....jpg",

                          helperText: "Paste any public image link",

                          prefixIcon: const Icon(Icons.image),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,

                        height: 55,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          onPressed: isLoading ? null : saveFood,

                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "ADD FOOD",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (imageUrlController.text.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imageUrlController.text,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(15),
                                ),

                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
