import 'package:flutter/material.dart';
import 'dart:async';
import 'user_profile_screen.dart';
import 'services/api_service.dart';

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
  List<
    Map<
      String,
      dynamic
    >
  >
  _allUsers = [];
  bool
  _isSearching = false;
  bool
  _isLoading = true;
  Timer?
  _debounce;
  Set<
    String
  >
  _followingUsers = {};

  @override
  void
  initState() {
    super.initState();
    _loadAllUsers();
    _searchController.addListener(
      _onSearchChanged,
    );
  }

  void
  _onSearchChanged() {
    if (_debounce?.isActive ??
        false)
      _debounce!.cancel();
    _debounce = Timer(
      const Duration(
        milliseconds: 300,
      ),
      () {
        _performSearch(
          _searchController.text,
        );
      },
    );
  }

  Future<
    void
  >
  _loadAllUsers() async {
    setState(
      () {
        _isLoading = true;
      },
    );

    try {
      // For now, we'll fetch all users - in production, you'd want pagination
      final response = await ApiService.searchUsers(
        '',
      );

      if (response['success']) {
        setState(
          () {
            _allUsers =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'] ??
                      [],
                );
            _searchResults = _allUsers;
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading users: $e',
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  void
  _performSearch(
    String query,
  ) {
    if (query.isEmpty) {
      setState(
        () {
          _searchResults = _allUsers;
          _isSearching = false;
        },
      );
      return;
    }

    setState(
      () {
        _isSearching = true;
        _searchResults = _allUsers.where(
          (
            user,
          ) {
            final username =
                user['username']?.toString().toLowerCase() ??
                '';
            final displayName =
                user['displayName']?.toString().toLowerCase() ??
                '';
            final searchLower = query.toLowerCase();
            return username.contains(
                  searchLower,
                ) ||
                displayName.contains(
                  searchLower,
                );
          },
        ).toList();
      },
    );
  }

  Future<
    void
  >
  _toggleFollow(
    String userId,
    bool isFollowing,
  ) async {
    try {
      if (isFollowing) {
        await ApiService.unfollowUser(
          userId,
        );
        setState(
          () {
            _followingUsers.remove(
              userId,
            );
          },
        );
      } else {
        await ApiService.followUser(
          userId,
        );
        setState(
          () {
            _followingUsers.add(
              userId,
            );
          },
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty
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
    final userId =
        user['_id'] ??
        user['id'] ??
        '';
    final isFollowing = _followingUsers.contains(
      userId,
    );

    return GestureDetector(
      onTap: () {
        // Navigate to user profile
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
            GestureDetector(
              onTap: () => _toggleFollow(
                userId,
                isFollowing,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isFollowing
                      ? null
                      : const LinearGradient(
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
                  color: isFollowing
                      ? Colors.grey[300]
                      : null,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  isFollowing
                      ? 'Following'
                      : 'Follow',
                  style: TextStyle(
                    color: isFollowing
                        ? Colors.grey[700]
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void
  dispose() {
    _debounce?.cancel();
    _searchController.removeListener(
      _onSearchChanged,
    );
    _searchController.dispose();
    super.dispose();
  }
}
