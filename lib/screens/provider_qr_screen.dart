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
    qrUrl = await firestoreService.getProviderQr();
    if (mounted) setState(() {});
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    Uint8List? selectedImageBytes;
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      imageBytes = bytes;
    });
  }

  Future<void> uploadQr() async {
    if (imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select QR Image")));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await firestoreService.uploadQrImageBytes(
        imageBytes!,
        firestoreService.currentUser!.uid,
      );

      qrUrl = await firestoreService.getProviderQr();

      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("QR Uploaded Successfully")));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: $e"),
          backgroundColor: Colors.red,
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
        title: const Text(
          "Payment QR",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 120,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: imageBytes != null
                  ? MemoryImage(imageBytes!)
                  : qrUrl.isNotEmpty
                  ? NetworkImage(qrUrl) as ImageProvider
                  : null,
              child: imageBytes == null && qrUrl.isEmpty
                  ? const Icon(Icons.qr_code, size: 80)
                  : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: pickImage,
                icon: const Icon(Icons.photo),
                label: const Text(
                  "Choose QR From Gallery",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
                  loading ? "Uploading..." : "Upload QR",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Upload your EasyPaisa / JazzCash / Bank QR.\nCustomers will use this QR to make payments.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
