import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'preview_screen.dart';
import 'services/thumbnail_service.dart';

class ThumbnailSelectorScreen extends StatefulWidget {
  final String videoPath;
  final String selectedPath;
  final String caption;
  final List<String> hashtags;
  final String? backgroundMusicId;

  const ThumbnailSelectorScreen({
    super.key,
    required this.videoPath,
    required this.selectedPath,
    required this.caption,
    required this.hashtags,
    this.backgroundMusicId,
  });

  @override
  State<ThumbnailSelectorScreen> createState() =>
      _ThumbnailSelectorScreenState();
}

class _ThumbnailSelectorScreenState extends State<ThumbnailSelectorScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ThumbnailService _thumbnailService = ThumbnailService();

  String? _selectedThumbnail;
  bool _isSelecting = false;
  bool _isGeneratingThumbnails = false;
  List<String> _generatedThumbnails = [];
  int _selectedGeneratedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Generate auto thumbnails when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAutoThumbnails();
    });
  }

  Future<void> _generateAutoThumbnails() async {
    if (!mounted) return;

    setState(() => _isGeneratingThumbnails = true);

    try {
      print('🎬 Generating auto thumbnails from video...');

      // Generate thumbnails at different timestamps
      final thumbnails = await _thumbnailService.generateMultipleThumbnails(
        videoPath: widget.videoPath,
        timeMs: [0, 1000, 2000, 3000], // 0ms, 1s, 2s, 3s
        maxWidth: 320,
        maxHeight: 240,
        quality: 70,
      );

      if (mounted) {
        setState(() {
          _generatedThumbnails = thumbnails;
          if (thumbnails.isNotEmpty) {
            _selectedGeneratedIndex = 0; // Select first by default
          }
          _isGeneratingThumbnails = false;
        });

        if (thumbnails.isNotEmpty) {
          print('✅ Generated ${thumbnails.length} auto thumbnails');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generated ${thumbnails.length} thumbnail options'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('⚠️ Error generating auto thumbnails: $e');
      if (mounted) {
        setState(() => _isGeneratingThumbnails = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate auto thumbnails'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
    String? selectedThumbnailPath;

    // Use custom thumbnail if selected, otherwise use auto-generated
    if (_selectedThumbnail != null) {
      selectedThumbnailPath = _selectedThumbnail;
    } else if (_selectedGeneratedIndex >= 0 &&
        _selectedGeneratedIndex < _generatedThumbnails.length) {
      selectedThumbnailPath = _generatedThumbnails[_selectedGeneratedIndex];
    }

    if (selectedThumbnailPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a thumbnail'),
          backgroundColor: Colors.red,
        ),
      );
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
          thumbnailPath: selectedThumbnailPath,
          backgroundMusicId: widget.backgroundMusicId,
        ),
      ),
    );
  }

  Future<void> _useAutoThumbnail() async {
    if (_selectedGeneratedIndex < 0 ||
        _selectedGeneratedIndex >= _generatedThumbnails.length) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto thumbnail selected!'),
        backgroundColor: Color(0xFF701CF5),
        duration: Duration(seconds: 1),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _proceedToPreview();
    }
  }

  @override
  void dispose() {
    // Cleanup generated thumbnails EXCEPT the selected one
    // The selected thumbnail will be cleaned up after upload in preview_screen
    final selectedPath =
        _selectedGeneratedIndex >= 0 &&
            _selectedGeneratedIndex < _generatedThumbnails.length
        ? _generatedThumbnails[_selectedGeneratedIndex]
        : null;

    final thumbnailsToCleanup = _generatedThumbnails
        .where((path) => path != selectedPath && path != _selectedThumbnail)
        .toList();

    if (thumbnailsToCleanup.isNotEmpty) {
      _thumbnailService.cleanupThumbnails(thumbnailsToCleanup);
    }
    super.dispose();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Show selected photo if available
            if (_selectedThumbnail != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF701CF5),
                          width: 3,
                        ),
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
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Custom Thumbnail Selected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )
            else if (_isGeneratingThumbnails)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF701CF5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Generating thumbnails...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            else if (_generatedThumbnails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto-Generated Thumbnails',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select one of these frames from your video',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Grid of auto-generated thumbnails
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _generatedThumbnails.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedGeneratedIndex == index;
                        final timestamps = ['0ms', '1s', '2s', '3s'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGeneratedIndex = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF701CF5)
                                    : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.file(
                                    File(_generatedThumbnails[index]),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                // Timestamp label
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      timestamps[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Selection checkmark
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF701CF5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Use Auto Thumbnail button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _useAutoThumbnail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF701CF5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Use Selected Thumbnail',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Or select custom photo
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isSelecting
                            ? null
                            : _selectPhotoFromGallery,
                        icon: _isSelecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF701CF5),
                                  ),
                                ),
                              )
                            : const Icon(Icons.photo_library),
                        label: Text(
                          _isSelecting
                              ? 'Opening Gallery...'
                              : 'Or Choose Custom Photo',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF701CF5),
                          side: const BorderSide(
                            color: Color(0xFF701CF5),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
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
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Choose any photo from your gallery to use as the video thumbnail',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Select photo button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton.icon(
                        onPressed: _isSelecting
                            ? null
                            : _selectPhotoFromGallery,
                        icon: _isSelecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),

            // Continue button (only show if custom photo is selected)
            if (_selectedThumbnail != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _proceedToPreview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF701CF5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
