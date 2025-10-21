import 'package:flutter/material.dart';
import 'user_profile_screen.dart';

class SearchScreen
    extends
        StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<
    SearchScreen
  >
  createState() => _SearchScreenState();
}

class _SearchScreenState
    extends
        State<
          SearchScreen
        > {
  final TextEditingController
  _searchController = TextEditingController();
  List<
    Map<
      String,
      dynamic
    >
  >
  _searchResults = [];
  bool
  _isSearching = false;

  // Sample user data
  final List<
    Map<
      String,
      dynamic
    >
  >
  _allUsers = [
    {
      'username': 'maria_dance',
      'displayName': 'Maria Rodriguez',
      'followers': '12.5K',
      'isVerified': true,
      'bio': 'Professional dancer & choreographer',
      'avatar': 'assets/profile/avatar1.png',
    },
    {
      'username': 'alex_mountain',
      'displayName': 'Alex Johnson',
      'followers': '8.9K',
      'isVerified': false,
      'bio': 'Adventure photographer',
      'avatar': 'assets/profile/avatar2.png',
    },
    {
      'username': 'sathon_bird',
      'displayName': 'Sathon Wildlife',
      'followers': '25.3K',
      'isVerified': true,
      'bio': 'Wildlife photographer & nature lover',
      'avatar': 'assets/profile/avatar3.png',
    },
    {
      'username': 'yada_tech',
      'displayName': 'Yada Tech',
      'followers': '45.2K',
      'isVerified': true,
      'bio': 'Tech reviews & tutorials',
      'avatar': 'assets/profile/avatar4.png',
    },
    {
      'username': 'emma_art',
      'displayName': 'Emma Creative',
      'followers': '6.7K',
      'isVerified': false,
      'bio': 'Digital artist & illustrator',
      'avatar': 'assets/profile/avatar5.png',
    },
    {
      'username': 'james_fitness',
      'displayName': 'James Strong',
      'followers': '18.1K',
      'isVerified': true,
      'bio': 'Fitness coach & nutritionist',
      'avatar': 'assets/profile/avatar6.png',
    },
    {
      'username': 'lisa_food',
      'displayName': 'Lisa Kitchen',
      'followers': '32.4K',
      'isVerified': true,
      'bio': 'Chef & food blogger',
      'avatar': 'assets/profile/avatar7.png',
    },
    {
      'username': 'mike_music',
      'displayName': 'Mike Melody',
      'followers': '15.8K',
      'isVerified': false,
      'bio': 'Musician & songwriter',
      'avatar': 'assets/profile/avatar8.png',
    },
  ];

  @override
  void
  initState() {
    super.initState();
    _searchResults = _allUsers; // Show all users initially
  }

  @override
  void
  dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void
  _performSearch(
    String query,
  ) {
    setState(
      () {
        _isSearching = query.isNotEmpty;
        if (query.isEmpty) {
          _searchResults = _allUsers;
        } else {
          _searchResults = _allUsers.where(
            (
              user,
            ) {
              final username = user['username'].toString().toLowerCase();
              final displayName = user['displayName'].toString().toLowerCase();
              final bio = user['bio'].toString().toLowerCase();
              final searchQuery = query.toLowerCase();

              return username.contains(
                    searchQuery,
                  ) ||
                  displayName.contains(
                    searchQuery,
                  ) ||
                  bio.contains(
                    searchQuery,
                  );
            },
          ).toList();
        }
      },
    );
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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _performSearch,
            decoration: const InputDecoration(
              hintText: 'Search profiles...',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search results header
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Row(
                children: [
                  Text(
                    '${_searchResults.length} results found',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          // Search results list
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          'No profiles found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final user = _searchResults[index];
                          return _buildUserTile(
                            user,
                          );
                        },
                  ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildUserTile(
    Map<
      String,
      dynamic
    >
    user,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => UserProfileScreen(
                  userInfo: user,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.05,
              ),
              blurRadius: 8,
              offset: const Offset(
                0,
                2,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile picture
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF701CF5,
                    ),
                    Color(
                      0xFF3E98E4,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(
              width: 12,
            ),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user['displayName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (user['isVerified'])
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 4,
                          ),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(
                              0xFF701CF5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    '@${user['username']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    user['bio'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${user['followers']} followers',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Follow button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
