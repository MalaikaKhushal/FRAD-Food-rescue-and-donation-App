import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'loginscreen.dart';
import 'dart:convert';
import 'dart:typed_data';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? currentUser;
  bool isLoading = true;
  bool isUploadingImage = false;

  final Color primaryColor = const Color(0xffF57C00);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await firestoreService.getCurrentUserData();
      if (mounted) {
        setState(() {
          currentUser = user;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // --- 📸 GALLERY SE IMAGE SELECT AUR BASE64 TEXT BANAKAR SAVE KARNA (CROSS-PLATFORM SAFE) ---
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40, // Safe memory size ke liye quality 40-50 rakhein
    );

    if (image == null) return;

    if (!mounted) return;
    setState(() {
      isUploadingImage = true;
    });

    try {
      // Direct XFile ke bytes read karenge jo har platform par chalta hai
      final Uint8List imageBytes = await image.readAsBytes();

      // Bytes ko Base64 String (Text) me convert karein
      String base64Image = base64Encode(imageBytes);

      // Data URL ready karein
      String dataUrl = "data:image/jpeg;base64,$base64Image";

      // Seedha Firestore me save karwa dein
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'imageUrl': dataUrl});

      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });

        _loadUserData(); // UI refresh

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile image updated successfully! 🎉"),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
          }
        });
      }
    }
  }

  // --- 📝 DYNAMIC EDIT PROFILE BOTTOM SHEET ---
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: currentUser?.fullName);
    final phoneController = TextEditingController(text: currentUser?.phone);
    final addressController = TextEditingController(
      text: currentUser?.address == "Not Provided" ? "" : currentUser?.address,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Profile Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.phone, color: primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => isLoading = true);
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.uid)
                          .update({
                            'fullName': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'address': addressController.text.trim().isEmpty
                                ? "Not Provided"
                                : addressController.text.trim(),
                          });
                      _loadUserData();
                    } catch (e) {
                      setState(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🔒 PASSWORD CHANGE FUNCTIONALITY ---
  void _showChangePasswordDialog() {
    final email = _auth.currentUser?.email;
    if (email == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Text(
          "We will send a password reset link to $email. Do you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _auth.sendPasswordResetEmail(email: email);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Password reset email sent! Check your inbox. 📨",
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              "Send Link",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getMemberSinceDate(dynamic dateField) {
    if (dateField == null) return "N/A";
    if (dateField is Timestamp) {
      DateTime dt = dateField.toDate();
      return "${dt.day}/${dt.month}/${dt.year}";
    }
    return dateField.toString();
  }

  Future<void> _logout() async {
    final bool? confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.black.withOpacity(0.4),
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
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
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
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  // --- 1️⃣ HEADER SECTION (IMAGE PREVIEW & PICKER WORKING SAFELY) ---
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // 🔍 CLICK HONE PAR IMAGE PREVIEW DIALOG OPEN HOGA
                                if (currentUser?.imageUrl != null &&
                                    currentUser!.imageUrl.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(15),
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Image.memory(
                                              base64Decode(
                                                currentUser!.imageUrl
                                                    .split(',')
                                                    .last,
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                // ✅ FIXED: Base64 decoder implemented instead of NetworkImage
                                backgroundImage:
                                    currentUser?.imageUrl != null &&
                                        currentUser!.imageUrl.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(
                                          currentUser!.imageUrl.split(',').last,
                                        ),
                                      ).image
                                    : null,
                                child:
                                    currentUser?.imageUrl == null ||
                                        currentUser!.imageUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: primaryColor,
                                      )
                                    : null,
                              ),
                            ),
                            if (isUploadingImage)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black26,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadImage,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: primaryColor,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentUser?.fullName ?? "User Name",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          currentUser?.email ?? "email@example.com",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- STATISTICS DASHBOARD ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.favorite,
                          "Saved",
                          firestoreService.getSavedFoodCount(),
                          Colors.red,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatItem(
                          Icons.shopping_bag,
                          "Orders",
                          firestoreService.getOrdersCount(),
                          primaryColor,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatItem(
                          Icons.notifications,
                          "Alerts",
                          firestoreService.getUnreadNotificationCount(),
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- 2️⃣ PERSONAL INFO SECTION ---
                  _buildSectionTitle("Personal Information"),
                  _buildInfoCard([
                    _buildInfoTile(
                      Icons.phone_outlined,
                      "Phone Number",
                      currentUser?.phone ?? "Not Provided",
                    ),
                    _buildInfoTile(
                      Icons.location_on_outlined,
                      "Address",
                      currentUser?.address ?? "Not Provided",
                    ),
                    _buildInfoTile(
                      Icons.calendar_today_outlined,
                      "Member Since",
                      _getMemberSinceDate(currentUser?.createdAt),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // --- 3️⃣ QUICK ACTIONS SECTION ---
                  _buildSectionTitle("Quick Actions"),
                  _buildInfoCard([
                    _buildActionTile(
                      Icons.edit_outlined,
                      "Edit Profile",
                      _showEditProfileDialog,
                    ),
                    _buildActionTile(
                      Icons.favorite_border_rounded,
                      "Saved Foods",
                      () => Navigator.pushNamed(context, "/savedFood"),
                    ),
                    _buildActionTile(
                      Icons.shopping_bag_outlined,
                      "My Orders",
                      () => Navigator.pushNamed(context, "/orders"),
                    ),
                    _buildActionTile(
                      Icons.notifications_none_rounded,
                      "Notifications",
                      () => Navigator.pushNamed(context, "/notifications"),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // --- 4️⃣ ACCOUNT & LEGAL SECTION ---
                  _buildSectionTitle("Account & Support"),
                  _buildInfoCard([
                    _buildActionTile(
                      Icons.lock_outline_rounded,
                      "Change Password",
                      _showChangePasswordDialog,
                    ),
                    _buildActionTile(
                      Icons.help_outline_rounded,
                      "Help & Support",
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Support team contact: support@frad.com 📞",
                            ),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      Icons.privacy_tip_outlined,
                      "Privacy Policy",
                      () {
                        showAboutDialog(
                          context: context,
                          applicationName: "FRAD",
                          applicationVersion: "1.0",
                          children: [
                            const Text(
                              "Your privacy is our priority. We protect your account details securely.",
                            ),
                          ],
                        );
                      },
                    ),
                    _buildActionTile(
                      Icons.info_outline_rounded,
                      "About FRAD",
                      () => Navigator.pushNamed(context, "/landing"),
                    ),
                  ]),
                  const SizedBox(height: 25),

                  // --- 5️⃣ LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.red.shade100),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    Stream<int> stream,
    Color color,
  ) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
