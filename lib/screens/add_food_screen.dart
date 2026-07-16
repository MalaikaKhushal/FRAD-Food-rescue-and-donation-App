import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ ADD THIS
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

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
  // =============================
  // CONTROLLERS
  // =============================
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
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = const Color(0xffF57C00);

  bool isLoading = false;
  bool donation = false;
  String selectedCategory = "Fast Food";

  File? _selectedImageFile;

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

  // ✅ Permission request function
  Future<bool> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.photos.isDenied ||
          await Permission.storage.isDenied) {
        return false;
      } else if (await Permission.photos.isDenied) {
        return false;
      }
    } else if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> requestCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  // ✅ Gallery se image select karo
  Future<void> pickImageFromGallery() async {
    try {
      // ✅ Request permission first
      bool hasPermission = await requestGalleryPermission();

      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gallery permission denied"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final compressedImage = await compressImage(imageFile);
        final bytes = await compressedImage.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = "data:image/jpeg;base64,$base64String";

        setState(() {
          _selectedImageFile = compressedImage;
          imageUrlController.text = dataUrl;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image selected successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Camera se photo lao
  Future<void> pickImageFromCamera() async {
    try {
      // ✅ Request permission first
      bool hasPermission = await requestCameraPermission();

      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera permission denied"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final compressedImage = await compressImage(imageFile);
        final bytes = await compressedImage.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = "data:image/jpeg;base64,$base64String";

        setState(() {
          _selectedImageFile = compressedImage;
          imageUrlController.text = dataUrl;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo captured successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Image compression
  Future<File> compressImage(File file) async {
    try {
      final image = img.decodeImage(await file.readAsBytes());
      if (image == null) return file;

      final compressedImage = img.encodeJpg(image, quality: 60);
      final compressedFile = File(file.path)..writeAsBytesSync(compressedImage);

      return compressedFile;
    } catch (e) {
      return file; // Return original if compression fails
    }
  }

  // ✅ URL paste dialog
  void showPasteUrlDialog() {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Paste Image URL"),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: "https://images.unsplash.com/...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.link),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() {
                  imageUrlController.text = urlController.text;
                  _selectedImageFile = null;
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Image URL added!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // =============================
  // SAVE FOOD TO FIRESTORE
  // =============================
  Future<void> saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add an image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = await firestoreService.getCurrentUserData();

      if (isEditing) {
        // ✅ EDIT MODE
        Map<String, dynamic> updatedData = {
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
          "imageUrl": imageUrlController.text.trim(),
        };

        String result = await firestoreService.updateFood(
          widget.food!.foodId,
          updatedData,
        );

        if (!mounted) return;

        if (result == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Food Updated Successfully"),
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(result);
        }
      } else {
        // ✅ ADD MODE
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

        String result = await firestoreService.addFood(food);

        if (!mounted) return;

        if (result == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Food Added Successfully"),
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception(result);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
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
                      const Icon(
                        Icons.fastfood,
                        size: 70,
                        color: Color(0xffF57C00),
                      ),
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

                      // ===== Food Name =====
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

                      // ===== Description =====
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

                      // ===== Category =====
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

                      // ===== Quantity =====
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

                      // ===== Original Price =====
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

                      // ===== Discount Price =====
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

                      // ===== Donation Switch =====
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

                      // ===== Pickup Information Header =====
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

                      // ===== Pickup Date =====
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
                            setState(() {
                              pickupDateController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ===== Pickup Time =====
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
                            setState(() {
                              pickupTimeController.text = pickedTime.format(
                                context,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ===== Expiry Time =====
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
                            setState(() {
                              expiryTimeController.text = pickedTime.format(
                                context,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ===== Location =====
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

                      // ===== IMAGE SECTION =====
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

                      // ✅ THREE OPTIONS BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: pickImageFromGallery,
                              icon: const Icon(Icons.image),
                              label: const Text("Gallery"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: pickImageFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Camera"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: showPasteUrlDialog,
                          icon: const Icon(Icons.link),
                          label: const Text("Paste URL"),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ✅ IMAGE PREVIEW
                      if (imageUrlController.text.isNotEmpty)
                        Column(
                          children: [
                            if (imageUrlController.text.startsWith(
                              "data:image",
                            ))
                              // Base64 image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.memory(
                                  base64Decode(
                                    imageUrlController.text.replaceAll(
                                      "data:image/jpeg;base64,",
                                      "",
                                    ),
                                  ),
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
                              )
                            else
                              // URL image
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
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  imageUrlController.clear();
                                  _selectedImageFile = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text("Remove Image"),
                            ),
                          ],
                        ),

                      const SizedBox(height: 30),

                      // ===== SUBMIT BUTTON =====
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
