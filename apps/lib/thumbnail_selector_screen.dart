import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'preview_screen.dart';

class ThumbnailSelectorScreen extends StatefulWidget {
  final String videoPath;
  final String selectedPath;
  final String caption;
  final List<String> hashtags;

  const ThumbnailSelectorScreen({
    super.key,
    required this.videoPath,
    required this.selectedPath,
    required this.caption,
    required this.hashtags,
  });

  @override
  State<ThumbnailSelectorScreen> createState() =>
      _ThumbnailSelectorScreenState();
}

class _ThumbnailSelectorScreenState extends State<ThumbnailSelectorScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedThumbnail;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    // Automatically open gallery when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectPhotoFromGallery();
    });
  }

  Future<void> _selectPhotoFromGallery() async {
    if (_isSelecting) return;

    setState(() => _isSelecting = true);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedThumbnail = image.path;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected as thumbnail!'),
            backgroundColor: Color(0xFF701CF5),
            duration: Duration(seconds: 1),
          ),
        );

        // Automatically proceed to preview after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _proceedToPreview();
        }
      } else {
        // User cancelled - go back
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select photo'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSelecting = false);
      }
    }
  }

  void _proceedToPreview() {
    if (_selectedThumbnail == null) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(
          selectedPath: widget.selectedPath,
          mediaPath: widget.videoPath,
          caption: widget.caption,
          hashtags: widget.hashtags,
          isVideo: true,
          thumbnailPath: _selectedThumbnail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Select Thumbnail',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show selected photo if available
            if (_selectedThumbnail != null)
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF701CF5), width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(
                    File(_selectedThumbnail!),
                    width: 300,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Gallery icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Select a Photo for Thumbnail',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Choose any photo from your gallery to use as the video thumbnail',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Select photo button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton.icon(
                      onPressed: _isSelecting ? null : _selectPhotoFromGallery,
                      icon: _isSelecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.photo_library),
                      label: Text(
                        _isSelecting ? 'Opening Gallery...' : 'Select Photo',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF701CF5),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Continue button (only show if photo is selected)
            if (_selectedThumbnail != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _proceedToPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF701CF5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
