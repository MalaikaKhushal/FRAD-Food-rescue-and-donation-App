import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'loginscreen.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? user;
  bool loading = true;
  bool saving = false;

  File? selectedImage;
  final picker = ImagePicker();

  static const Color primary = Colors.orange;
  static const Color bg = Color(0xffF5F6FA);

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await firestoreService.getCurrentUserData();
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> saveImage() async {
    if (selectedImage == null) return;

    setState(() => saving = true);
    try {
      String imageUrl = await firestoreService.uploadProfileImage(
        selectedImage!,
        user!.uid,
      );
      await firestoreService.updateProfileImage(imageUrl);
      await loadUser();

      if (!mounted) return;
      setState(() {
        selectedImage = null;
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile photo updated"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
    if (loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        centerTitle: true,
        title: const Text(
          "Provider Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            const SizedBox(height: 28),
            _buildAvatar(),
            const SizedBox(height: 16),
            Text(
              user!.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user!.email,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionLabel("Quick Actions"),
            _buildActionsCard([
              _ActionItem(Icons.storefront, "My Listings", () {
                Navigator.pushNamed(context, "/myListings");
              }),
              _ActionItem(Icons.receipt_long, "My Orders", () {
                Navigator.pushNamed(context, "/providerOrders");
              }),
              _ActionItem(Icons.favorite, "My Donations", () {
                Navigator.pushNamed(context, "/donations");
              }),
              _ActionItem(Icons.notifications_none, "Notifications", () {
                Navigator.pushNamed(context, "/notifications");
              }),
            ]),
            const SizedBox(height: 20),
            _buildSectionLabel("Account & Support"),
            _buildActionsCard([
              _ActionItem(Icons.lock_outline, "Change Password", () {}),
              _ActionItem(Icons.help_outline, "Help & Support", () {}),
              _ActionItem(Icons.shield_outlined, "Privacy Policy", () {}),
              _ActionItem(Icons.info_outline, "About FRAD", () {}),
            ]),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: logout, // Connected to logout logic
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectedImage != null ? _buildSaveBar() : null,
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: primary.withOpacity(0.12),
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!) as ImageProvider
                  : (user!.profileImage != null &&
                        user!.profileImage!.isNotEmpty)
                  ? NetworkImage(user!.profileImage!) as ImageProvider
                  : null,
              child:
                  selectedImage == null &&
                      (user!.profileImage == null ||
                          user!.profileImage!.isEmpty)
                  ? const Icon(Icons.storefront, size: 50, color: primary)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: pickImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statColumn(
              "Listings",
              Icons.fastfood,
              Colors.orange,
              firestoreService.getTotalListings(),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 8,
            endIndent: 8,
          ),
          Expanded(
            child: _statColumn(
              "Orders",
              Icons.receipt_long,
              Colors.green,
              firestoreService.getTotalReservations(),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 8,
            endIndent: 8,
          ),
          Expanded(
            child: _statColumn(
              "Donations",
              Icons.favorite,
              Colors.red,
              firestoreService.getTotalDonations(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(
    String title,
    IconData icon,
    Color color,
    Stream<int> stream,
  ) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              "${snapshot.data ?? 0}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _infoTile(Icons.phone, "Phone", user!.phone),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _infoTile(Icons.badge_outlined, "Role", user!.role),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _infoTile(
            Icons.location_on_outlined,
            "Address",
            (user!.address == null || user!.address!.isEmpty)
                ? "Not Provided"
                : user!.address!,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(
        title,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCard(List<_ActionItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: Colors.grey.shade700),
                title: Text(item.label, style: const TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: item.onTap,
              ),
              if (i != items.length - 1)
                const Divider(height: 1, indent: 20, endIndent: 20),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: saving
                    ? null
                    : () => setState(() => selectedImage = null),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: saving ? null : saveImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white, size: 18),
                label: Text(
                  saving ? "Saving..." : "Save Photo",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ActionItem(this.icon, this.label, this.onTap);
}
