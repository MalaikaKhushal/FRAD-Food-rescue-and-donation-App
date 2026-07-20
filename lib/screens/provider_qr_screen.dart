import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';

class ProviderQrScreen extends StatefulWidget {
  const ProviderQrScreen({super.key});

  @override
  State<ProviderQrScreen> createState() => _ProviderQrScreenState();
}

class _ProviderQrScreenState extends State<ProviderQrScreen> {
  final FirestoreService firestoreService = FirestoreService();

  Uint8List? imageBytes;
  String qrUrl = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadQr();
  }

  Future<void> loadQr() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    try {
      final fetchedUrl = await firestoreService.getProviderQr();
      if (mounted) {
        setState(() {
          qrUrl = fetchedUrl;
        });
      }
    } catch (e) {
      debugPrint("Error loading QR: $e");
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future<void> uploadQr() async {
    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a QR image first")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final userId = firestoreService.currentUser?.uid;
      if (userId == null) {
        throw "User not logged in. Please sign in again.";
      }

      // 1. Storage me upload
      await firestoreService.uploadQrImageBytes(imageBytes!, userId);

      // 2. Fresh QR URL retrieve karna
      final newQrUrl = await firestoreService.getProviderQr();

      if (!mounted) return;

      setState(() {
        qrUrl = newQrUrl;
        imageBytes = null; // Memory clear karke network image switch
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment QR Uploaded Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      // Shows exact error on screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Payment QR Code",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Square Frame for QR Code Display
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: buildQrImageWidget(),
              ),
            ),

            const SizedBox(height: 30),

            // Choose Image Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text(
                  "Choose QR From Gallery",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : uploadQr,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  loading ? "Uploading..." : "Upload QR Code",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Info Box
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Upload EasyPaisa, JazzCash, or Bank QR. Customers will scan this to send payments.",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display Preview / Existing QR / Placeholder
  Widget buildQrImageWidget() {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, fit: BoxFit.contain);
    }

    if (qrUrl.isNotEmpty) {
      return Image.network(
        qrUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_2, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          "No QR Uploaded",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}
