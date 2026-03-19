import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptUploadCard extends StatefulWidget {
  const ReceiptUploadCard({super.key});

  @override
  State<ReceiptUploadCard> createState() => _ReceiptUploadCardState();
}

class _ReceiptUploadCardState extends State<ReceiptUploadCard> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mockUpload() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a receipt image first')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt selected successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _selectedImage!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 52,
                    color: Color(0xFF1565C0),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No receipt selected',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Upload booking receipt',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a receipt from your gallery or take a photo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showPickerOptions,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Choose'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _mockUpload,
                  icon: const Icon(Icons.upload),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}