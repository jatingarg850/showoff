import 'package:flutter/material.dart';
import 'community_chat_screen.dart';
import 'services/api_service.dart';

class CommunityScreen
    extends
        StatefulWidget {
  const CommunityScreen({
    super.key,
  });

  @override
  State<
    CommunityScreen
  >
  createState() => _CommunityScreenState();
}

class _CommunityScreenState
    extends
        State<
          CommunityScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _groups = [];
  bool
  _isLoading = true;
  String?
  _selectedCategory;

  final List<
    String
  >
  _categories = [
    'All',
    'Arts',
    'Dance',
    'Drama',
    'Music',
    'Sports',
    'Technology',
    'Fashion',
    'Food',
    'Travel',
    'Other',
  ];

  @override
  void
  initState() {
    super.initState();
    _loadGroups();
  }

  Future<
    void
  >
  _loadGroups() async {
    try {
      final response = await ApiService.getGroups(
        category: _selectedCategory,
      );
      if (response['success']) {
        setState(
          () {
            _groups =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'],
                );
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading groups: $e',
      );
      setState(
        () => _isLoading = false,
      );
    }
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
        title: const Text(
          'Community',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Category filter chips
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                        final category = _categories[index];
                        final isSelected =
                            _selectedCategory ==
                                category ||
                            (_selectedCategory ==
                                    null &&
                                category ==
                                    'All');
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: FilterChip(
                            label: Text(
                              category,
                            ),
                            selected: isSelected,
                            onSelected:
                                (
                                  selected,
                                ) {
                                  setState(
                                    () {
                                      _selectedCategory =
                                          category ==
                                              'All'
                                          ? null
                                          : category;
                                      _isLoading = true;
                                    },
                                  );
                                  _loadGroups();
                                },
                            selectedColor: const Color(
                              0xFF8B5CF6,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            backgroundColor: Colors.grey[200],
                            checkmarkColor: Colors.white,
                          ),
                        );
                      },
                ),
              ),

              // Scrollable content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _groups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.group_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                              'No communities yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Be the first to create one!',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadGroups,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                            20,
                          ),
                          itemCount: _groups.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final group = _groups[index];
                                // Use default images based on category
                                String backgroundImage = 'assets/community/arts_bg.jpg';
                                switch (group['category']) {
                                  case 'Dance':
                                    backgroundImage = 'assets/community/dance_bg.jpg';
                                    break;
                                  case 'Drama':
                                    backgroundImage =
                                        index %
                                                2 ==
                                            0
                                        ? 'assets/community/drama_bg.jpg'
                                        : 'assets/community/drama2_bg.jpg';
                                    break;
                                  case 'Arts':
                                    backgroundImage = 'assets/community/arts_bg.jpg';
                                    break;
                                  default:
                                    backgroundImage = 'assets/community/dark_bg.jpg';
                                }

                                return Column(
                                  children: [
                                    _buildCommunityCard(
                                      context,
                                      title:
                                          group['name'] ??
                                          '',
                                      members: '${group['membersCount'] ?? 0}',
                                      category:
                                          group['category'] ??
                                          '',
                                      backgroundImage: backgroundImage,
                                      categoryColor: const Color(
                                        0xFF8B5CF6,
                                      ),
                                      groupId: group['_id'],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                );
                              },
                        ),
                      ),
              ),
            ],
          ),

          // Fixed floating action buttons
          Positioned(
            right: 20,
            bottom: 120,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFF8B5CF6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                GestureDetector(
                  onTap: () => _showCreateGroupBottomSheet(
                    context,
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void
  _showCreateGroupBottomSheet(
    BuildContext context,
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Arts';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (
            context,
          ) => StatefulBuilder(
            builder:
                (
                  context,
                  setModalState,
                ) => Container(
                  height:
                      MediaQuery.of(
                        context,
                      ).size.height *
                      0.75,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        20,
                      ),
                      topRight: Radius.circular(
                        20,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(
                                2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // Title
                        const Text(
                          'Group details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 32,
                        ),

                        // Group category
                        const Text(
                          'Group category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        DropdownButtonFormField<
                          String
                        >(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                          items: _categories
                              .where(
                                (
                                  c,
                                ) =>
                                    c !=
                                    'All',
                              )
                              .map(
                                (
                                  category,
                                ) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged:
                              (
                                value,
                              ) {
                                setModalState(
                                  () {
                                    selectedCategory = value!;
                                  },
                                );
                              },
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // Group Name
                        const Text(
                          'Group Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Group name',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // Group Description
                        const Text(
                          'Group Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Describe your community...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF8B5CF6,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // Create button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isEmpty ||
                                  descriptionController.text.isEmpty) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill all fields',
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                final response = await ApiService.createGroup(
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  category: selectedCategory,
                                );

                                if (response['success']) {
                                  Navigator.pop(
                                    context,
                                  );
                                  _loadGroups();
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Community created successfully!',
                                      ),
                                    ),
                                  );
                                }
                              } catch (
                                e
                              ) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF8B5CF6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Create Community',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget
  _buildCommunityCard(
    BuildContext context, {
    required String title,
    required String members,
    required String category,
    required String backgroundImage,
    required Color categoryColor,
    String? groupId,
    bool isLastCard = false,
  }) {
    return GestureDetector(
      onTap:
          groupId !=
              null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => CommunityChatScreen(
                        groupId: groupId,
                        communityName: title,
                      ),
                ),
              );
            }
          : null,
      child: Container(
        height: isLastCard
            ? 120
            : 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            16,
          ),
          color: Colors.grey[300], // Fallback color
        ),
        child: Stack(
          children: [
            // Background with overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                color: isLastCard
                    ? const Color(
                        0xFF2D3748,
                      )
                    : Colors.grey[600],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(
                        alpha: 0.3,
                      ),
                      Colors.black.withValues(
                        alpha: 0.7,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            if (!isLastCard)
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // Bottom row with members and category
                    Row(
                      children: [
                        // Members count
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              members,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.apps,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Join button
                        if (groupId !=
                            null)
                          GestureDetector(
                            onTap: () async {
                              try {
                                final response = await ApiService.joinGroup(
                                  groupId,
                                );
                                if (response['success']) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Joined successfully!',
                                      ),
                                    ),
                                  );
                                  _loadGroups();
                                }
                              } catch (
                                e
                              ) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: const Text(
                                'Join',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
