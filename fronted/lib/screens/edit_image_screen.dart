import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditImageScreen extends ConsumerStatefulWidget {
  final String? imageUrl; // Can be null if user picks a new image

  const EditImageScreen({super.key, this.imageUrl});

  @override
  ConsumerState<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends ConsumerState<EditImageScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  // TODO: Add state for drawing mask and handling prompt

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null) {
      // TODO: Load image from URL into a file or memory
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑图片'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Implement image editing logic
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // TODO: Replace with an interactive image canvas for drawing masks
                  child: Image.file(_imageFile!),
                ),
              )
            else
              _buildImagePickerButton(),
            
            // TODO: Add prompt input field
            // TODO: Add editing tools (e.g., brush, eraser)
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('从相册选择'),
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 20),
        const Text('或者'),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // TODO: Navigate from an existing image
             if (widget.imageUrl != null) {
                // Logic to handle passed image url
             } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('没有可用的传入图像')),
                );
             }
          },
          child: const Text('使用传入的图像'),
        )
      ],
    );
  }
}