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
              // Category filter
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
                            ),
                          ),
                        );
                      },
                ),
              ),

              // Groups list
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
                                return _buildCommunityCard(
                                  context,
                                  group: group,
                                );
                              },
                        ),
                      ),
              ),
            ],
          ),

          // Floating action buttons
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

  Widget
  _buildCommunityCard(
    BuildContext context, {
    required Map<
      String,
      dynamic
    >
    group,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => CommunityChatScreen(
                  groupId: group['_id'],
                  communityName: group['name'],
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            16,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(
                0xFF8B5CF6,
              ),
              const Color(
                0xFF3B82F6,
              ),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image if available
            if (group['coverImage'] !=
                null)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                child: Image.network(
                  ApiService.getImageUrl(
                    group['coverImage'],
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container();
                      },
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(
                      0.7,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF8B5CF6,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      group['category'] ??
                          'General',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Title
                  Text(
                    group['name'] ??
                        '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // Description
                  Text(
                    group['description'] ??
                        '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(
                        0.9,
                      ),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Members count
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${group['membersCount'] ?? 0} members',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom:
                          MediaQuery.of(
                            context,
                          ).viewInsets.bottom +
                          24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Community',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),

                        // Name field
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Community Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),

                        // Description field
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),

                        // Category dropdown
                        DropdownButtonFormField<
                          String
                        >(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
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
}
