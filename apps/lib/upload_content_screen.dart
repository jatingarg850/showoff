import 'package:flutter/material.dart';
import 'preview_screen.dart';

class UploadContentScreen
    extends
        StatefulWidget {
  final String
  selectedPath; // 'reels' or 'arena'
  final String?
  mediaPath; // Path to captured photo/video

  const UploadContentScreen({
    super.key,
    required this.selectedPath,
    this.mediaPath,
  });

  @override
  State<
    UploadContentScreen
  >
  createState() => _UploadContentScreenState();
}

class _UploadContentScreenState
    extends
        State<
          UploadContentScreen
        > {
  final TextEditingController
  _captionController = TextEditingController();
  String?
  selectedCategory;

  final List<
    String
  >
  categories = [
    'Dance',
    'Music',
    'Art',
    'Comedy',
    'Sports',
    'Education',
    'Lifestyle',
    'Food',
    'Travel',
    'Fashion',
  ];

  @override
  void
  dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: ShaderMask(
          shaderCallback:
              (
                bounds,
              ) =>
                  const LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF3E98E4,
                      ),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                    bounds,
                  ),
          child: const Text(
            'Upload your content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),

            // Category Section
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Category Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(
                    0xFF701CF5,
                  ),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child:
                    DropdownButton<
                      String
                    >(
                      value: selectedCategory,
                      hint: const Text(
                        'Select a category',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(
                          0xFF701CF5,
                        ),
                      ),
                      items: categories.map(
                        (
                          String category,
                        ) {
                          return DropdownMenuItem<
                            String
                          >(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged:
                          (
                            String? newValue,
                          ) {
                            setState(
                              () {
                                selectedCategory = newValue;
                              },
                            );
                          },
                    ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // Caption Section
            const Text(
              'Caption',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Caption Text Area
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(
                    0xFF701CF5,
                  ),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: TextField(
                controller: _captionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write something about yourself',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(
                    16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),

            const Spacer(),

            // Preview Button
            Center(
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF74B9FF,
                      ),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to preview screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => PreviewScreen(
                              selectedPath: widget.selectedPath,
                              mediaPath: widget.mediaPath,
                              category: selectedCategory,
                              caption: _captionController.text,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
