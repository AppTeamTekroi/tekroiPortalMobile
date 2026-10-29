import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadBox extends StatefulWidget {
  final bool showPicker; // 🔥 control UI
  final VoidCallback onTap;
  final VoidCallback onFileRemoved;
  final Function(File file)? onFileSelected;

  UploadBox({
    Key? key,
    required this.showPicker,
    required this.onTap,
    this.onFileSelected,
    required this.onFileRemoved,
  }) : super(key: key);

  @override
  State<UploadBox> createState() => _UploadBoxState();
}

class _UploadBoxState extends State<UploadBox> {

  File? selectedFile;

  /// 📸 Camera / 🖼️ Gallery (system photo picker, no storage permission needed)
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      requestFullMetadata: false, // helps avoid metadata-related failures on some Android devices
    );

    if (pickedFile == null) {
      print("📸 Image pick cancelled or permission denied");
      return;
    }

    final file = File(pickedFile.path);

    if (!await file.exists()) {
      print("⚠️ Picker returned a path that doesn't exist yet: ${pickedFile.path}");
      return;
    }

    if (!mounted) return;

    setState(() {
      selectedFile = file;
      print("📁 SELECTED FILE => ${file.path}");
    });

    widget.onFileSelected?.call(file);
  }

  Future<void> _showSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 STEP 1: Show Upload Box
    if (!widget.showPicker) {
      return GestureDetector(
        onTap: _showSourceSheet,
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: selectedFile == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.upload, size: 40, color: Colors.grey),
                SizedBox(height: 10),
                Text("Click to upload bill"),
                SizedBox(height: 4),
                Text(
                  "JPG, PNG (max 5MB)",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
                :  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Flexible(
                      child: Image.file(
                        selectedFile!,
                        fit: BoxFit.fill,

                      ),
                    ),
                    // ❌ Remove Button (HERE)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedFile = null;
                          widget.onFileRemoved();
                        });
                      },
                    ),
                  ],
                )
        ),
      );
    }

    /// 🔥 STEP 2: Show Camera + Gallery
    return Column(
      children: [
        _sourceTile(Icons.camera_alt, () => pickImage(ImageSource.camera)),
        _sourceTile(Icons.photo_library, () => pickImage(ImageSource.gallery)),
      ],
    );
  }

  Widget _sourceTile(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(icon, size: 30),
        ),
      ),
    );
  }
}
