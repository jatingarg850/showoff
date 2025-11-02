import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'community_chat_screen.dart';
import 'services/api_service.dart';

class EnhancedCommunityScreen
    extends
        StatefulWidget {
  const EnhancedCommunityScreen({
    super.key,
  });

  @override
  State<
    EnhancedCommunityScreen
  >
  createState() => _EnhancedCommunityScreenState();
}

class _EnhancedCommunityScreenState
    extends
        State<
          EnhancedCommunityScreen
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
                                return Column(
                                  children: [
                                    _buildEnhancedCommunityCard(
                                      context,
                                      group: group,
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

          // Fixed floating action button
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showCreateGroupBottomSheet(
                context,
              ),
              backgroundColor: const Color(
                0xFF8B5CF6,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildEnhancedCommunityCard(
    BuildContext context, {
    required Map<
      String,
      dynamic
    >
    group,
  }) {
    final groupId = group['_id'];
    final name =
        group['name'] ??
        '';
    final description =
        group['description'] ??
        '';
    final category =
        group['category'] ??
        '';
    final membersCount =
        group['membersCount'] ??
        0;
    final bannerImage = group['bannerImage'];
    final logoImage = group['logoImage'];

    return FutureBuilder<
      Map<
        String,
        dynamic
      >
    >(
      future: ApiService.checkGroupMembership(
        groupId,
      ),
      builder:
          (
            context,
            snapshot,
          ) {
            bool isMember = false;
            bool isCreator = false;

            if (snapshot.hasData &&
                snapshot.data!['success']) {
              isMember =
                  snapshot.data!['data']['isMember'] ??
                  false;
              isCreator =
                  snapshot.data!['data']['isCreator'] ??
                  false;
            }

            return GestureDetector(
              onTap: isMember
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => CommunityChatScreen(
                                groupId: groupId,
                                communityName: name,
                              ),
                        ),
                      );
                    }
                  : null,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  color: Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    // Banner background
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        image:
                            bannerImage !=
                                null
                            ? DecorationImage(
                                image: NetworkImage(
                                  ApiService.getImageUrl(
                                    bannerImage,
                                  ),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient:
                            bannerImage ==
                                null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(
                                    0xFF8B5CF6,
                                  ),
                                  Color(
                                    0xFF3B82F6,
                                  ),
                                ],
                              )
                            : null,
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
                    Padding(
                      padding: const EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row with logo and category
                          Row(
                            children: [
                              // Logo
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  image:
                                      logoImage !=
                                          null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            ApiService.getImageUrl(
                                              logoImage,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child:
                                    logoImage ==
                                        null
                                    ? Icon(
                                        Icons.group,
                                        color: Color(
                                          0xFF8B5CF6,
                                        ),
                                        size: 24,
                                      )
                                    : null,
                              ),
                              const Spacer(),
                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Title and description
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // Bottom row with members and action button
                          Row(
                            children: [
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
                                    '$membersCount members',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Action button
                              GestureDetector(
                                onTap: isMember
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => CommunityChatScreen(
                                                  groupId: groupId,
                                                  communityName: name,
                                                ),
                                          ),
                                        );
                                      }
                                    : () async {
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
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            setState(
                                              () {},
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
                                              backgroundColor: Colors.red,
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
                                    color: isMember
                                        ? Colors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMember
                                            ? Icons.chat
                                            : Icons.add,
                                        size: 16,
                                        color: isMember
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        isMember
                                            ? 'Chat'
                                            : 'Join',
                                        style: TextStyle(
                                          color: isMember
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
          },
    );
  }

  void
  _showCreateGroupBottomSheet(
    BuildContext context,
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Arts';
    File? bannerImage;
    File? logoImage;
    bool isCreating = false;

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
                      0.8,
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
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
                            'Create Community',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // Banner Image Section
                          const Text(
                            'Banner Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1920,
                                maxHeight: 1080,
                                imageQuality: 85,
                              );
                              if (image !=
                                  null) {
                                setModalState(
                                  () {
                                    bannerImage = File(
                                      image.path,
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                                image:
                                    bannerImage !=
                                        null
                                    ? DecorationImage(
                                        image: FileImage(
                                          bannerImage!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  bannerImage ==
                                      null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 40,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          'Add Banner Image',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // Logo Image Section
                          const Text(
                            'Logo Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 512,
                                    maxHeight: 512,
                                    imageQuality: 85,
                                  );
                                  if (image !=
                                      null) {
                                    setModalState(
                                      () {
                                        logoImage = File(
                                          image.path,
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    image:
                                        logoImage !=
                                            null
                                        ? DecorationImage(
                                            image: FileImage(
                                              logoImage!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      logoImage ==
                                          null
                                      ? Icon(
                                          Icons.add_a_photo,
                                          size: 30,
                                          color: Colors.grey[600],
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Text(
                                  'Add a logo for your community. This will be displayed as the group icon.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // Category
                          const Text(
                            'Category',
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
                            height: 16,
                          ),

                          // Name
                          const Text(
                            'Community Name',
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
                              hintText: 'Enter community name',
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
                            height: 16,
                          ),

                          // Description
                          const Text(
                            'Description',
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
                              onPressed: isCreating
                                  ? null
                                  : () async {
                                      if (nameController.text.isEmpty ||
                                          descriptionController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please fill all required fields',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(
                                        () {
                                          isCreating = true;
                                        },
                                      );

                                      try {
                                        final response = await ApiService.createGroup(
                                          name: nameController.text,
                                          description: descriptionController.text,
                                          category: selectedCategory,
                                          bannerImage: bannerImage,
                                          logoImage: logoImage,
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
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          throw Exception(
                                            response['message'] ??
                                                'Failed to create community',
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
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        setModalState(
                                          () {
                                            isCreating = false;
                                          },
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
                              child: isCreating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<
                                              Color
                                            >(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
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
          ),
    );
  }
}
