import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';
import '../services/firestore_service.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodModel? food;
  const AddFoodScreen({super.key, this.food});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController discountPriceController = TextEditingController();
  final TextEditingController pickupDateController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController expiryTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = const Color(0xffF57C00);

  bool isLoading = false;
  bool donation = false;
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

  bool get isEditing => widget.food != null;

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
    imageUrlController.dispose();
    super.dispose();
  }

  void showPasteUrlDialog() {
    final urlController = TextEditingController(text: imageUrlController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Paste Image URL"),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: "https://example.com/image.jpg",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.link, color: primaryColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() {
                  imageUrlController.text = urlController.text.trim();
                });
                Navigator.pop(context);
                showSnackBar("Image URL added!", Colors.green);
              }
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageUrlController.text.isEmpty) {
      showSnackBar("Please add an image URL", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = await firestoreService.getCurrentUserData();
      String foodId = isEditing
          ? widget.food!.foodId
          : FirebaseFirestore.instance.collection("food_listings").doc().id;

      String finalImageUrl = imageUrlController.text.trim();

      Map<String, dynamic> foodData = {
        "foodId": foodId,
        "providerId": currentUser.uid,
        "providerName": currentUser.fullName,
        "providerType": currentUser.role,
        "foodName": foodNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "category": selectedCategory,
        "quantity": int.parse(quantityController.text.trim()),
        "originalPrice": double.parse(originalPriceController.text.trim()),
        "discountPrice": double.parse(discountPriceController.text.trim()),
        "donation": donation,
        "pickupDate": pickupDateController.text.trim(),
        "pickupTime": pickupTimeController.text.trim(),
        "expiryTime": expiryTimeController.text.trim(),
        "location": locationController.text.trim(),
        "imageUrl": finalImageUrl,
        "status": "Available",
        "createdAt": Timestamp.now(),
      };

      String result;
      if (isEditing) {
        result = await firestoreService.updateFood(
          widget.food!.foodId,
          foodData,
        );
      } else {
        FoodModel foodObj = FoodModel.fromMap(foodData);
        result = await firestoreService.addFood(foodObj);
      }

      if (!mounted) return;

      if (result == "success") {
        showSnackBar(
          isEditing ? "Food Updated Successfully" : "Food Added Successfully",
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(result);
      }
    } catch (e) {
      showSnackBar(e.toString(), Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? "Edit Food" : "Add Food",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                      Icon(Icons.fastfood, size: 70, color: primaryColor),
                      const SizedBox(height: 10),
                      Text(
                        isEditing
                            ? "Edit Food Listing"
                            : "Add New Food Listing",
                        style: const TextStyle(
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
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter Food Name"
                            : null,
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
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter Description"
                            : null,
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
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedCategory = value!),
                      ),
                      const SizedBox(height: 20),

                      // Quantity
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter Quantity"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Available Quantity",
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Original Price
                      TextFormField(
                        controller: originalPriceController,
                        keyboardType: TextInputType.number,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter Original Price"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Original Price",
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Discount Price
                      TextFormField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            (!donation && (value == null || value.isEmpty))
                            ? "Enter Discount Price"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Discount Price",
                          prefixIcon: const Icon(Icons.local_offer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Donation Switch
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
                            Icon(Icons.volunteer_activism, color: primaryColor),
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
                                  if (donation)
                                    discountPriceController.text = "0";
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

                      // Pickup Date
                      TextFormField(
                        controller: pickupDateController,
                        readOnly: true,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Select Pickup Date"
                            : null,
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
                            setState(() {
                              pickupDateController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pickup Time
                      TextFormField(
                        controller: pickupTimeController,
                        readOnly: true,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Select Pickup Time"
                            : null,
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
                            setState(() {
                              pickupTimeController.text = pickedTime.format(
                                context,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Expiry Time
                      TextFormField(
                        controller: expiryTimeController,
                        readOnly: true,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Select Expiry Time"
                            : null,
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
                            setState(() {
                              expiryTimeController.text = pickedTime.format(
                                context,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Location
                      TextFormField(
                        controller: locationController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter Pickup Location"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Pickup Location",
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // IMAGE SECTION
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Food Image",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ MATCHED WITH BRAND THEME (ORANGE)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: showPasteUrlDialog,
                          icon: const Icon(Icons.link, color: Colors.white),
                          label: const Text(
                            "Paste Image URL",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // IMAGE PREVIEW AREA
                      if (imageUrlController.text.isNotEmpty)
                        Column(
                          children: [
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
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Text(
                                        "Invalid Image URL\n(Make sure it's a direct image link)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  imageUrlController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear, color: Colors.red),
                              label: const Text(
                                "Remove Image",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 30),

                      // SUBMIT BUTTON
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
                              : Text(
                                  isEditing ? "UPDATE FOOD" : "ADD FOOD",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
