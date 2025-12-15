import 'package:flutter/material.dart';
import 'dart:async';
import 'user_profile_screen.dart';
import 'services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allUsers = [];
  bool _isSearching = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  Timer? _debounce;
  final Set<String> _followingUsers = {};

  // Pagination variables
  int _currentPage = 1;
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoadingMore && _hasMoreData && !_isSearching) {
        _loadMoreUsers();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh follow status when returning to this screen
    if (_allUsers.isNotEmpty) {
      _refreshFollowStatus();
    }
  }

  Future<void> _refreshFollowStatus() async {
    if (_allUsers.isEmpty) return;

    // Clear current follow status and reload
    _followingUsers.clear();
    await _loadFollowStatus(_allUsers);

    if (mounted) {
      setState(() {
        // Trigger rebuild with updated follow status
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
      _allUsers = [];
      _searchResults = [];
    });

    try {
      // Fetch first page of users with pagination
      final response = await ApiService.searchUsers(
        '',
        page: _currentPage,
        limit: _pageSize,
      );

      if (response['success']) {
        final users = List<Map<String, dynamic>>.from(response['data'] ?? []);

        // Check if there are more users to load
        final totalCount = response['total'] ?? 0;
        final loadedCount = _currentPage * _pageSize;
        _hasMoreData = loadedCount < totalCount;

        // Check follow status for each user
        await _loadFollowStatus(users);

        setState(() {
          _allUsers = users;
          _searchResults = _allUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final response = await ApiService.searchUsers(
        '',
        page: _currentPage,
        limit: _pageSize,
      );

      if (response['success']) {
        final newUsers = List<Map<String, dynamic>>.from(
          response['data'] ?? [],
        );

        if (newUsers.isEmpty) {
          setState(() {
            _hasMoreData = false;
            _isLoadingMore = false;
          });
          return;
        }

        // Check follow status for new users
        await _loadFollowStatus(newUsers);

        setState(() {
          _allUsers.addAll(newUsers);
          _searchResults = _allUsers;
          _isLoadingMore = false;

          // Check if there are more users to load
          final totalCount = response['total'] ?? 0;
          final loadedCount = _currentPage * _pageSize;
          _hasMoreData = loadedCount < totalCount;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page increment on error
      });
    }
  }

  Future<void> _loadFollowStatus(List<Map<String, dynamic>> users) async {
    try {
      // Check follow status for each user
      for (final user in users) {
        final userId = user['_id'] ?? user['id'] ?? '';
        if (userId.isNotEmpty) {
          try {
            final followResponse = await ApiService.checkFollowing(userId);
            if (followResponse['success'] == true &&
                followResponse['isFollowing'] == true) {
              _followingUsers.add(userId);
            }
          } catch (e) {
            // Continue if individual follow check fails
            print('Error checking follow status for user $userId: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading follow status: $e');
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _allUsers;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allUsers.where((user) {
        final username = user['username']?.toString().toLowerCase() ?? '';
        final displayName = user['displayName']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return username.contains(searchLower) ||
            displayName.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _toggleFollow(String userId, bool isFollowing) async {
    try {
      if (isFollowing) {
        final response = await ApiService.unfollowUser(userId);
        if (response['success']) {
          setState(() {
            _followingUsers.remove(userId);
          });

          // Refresh user data to get updated followers count
          await _refreshUserData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unfollowed successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception(response['message'] ?? 'Failed to unfollow');
        }
      } else {
        final response = await ApiService.followUser(userId);
        if (response['success']) {
          setState(() {
            _followingUsers.add(userId);
          });

          // Refresh user data to get updated followers count
          await _refreshUserData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Followed successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception(response['message'] ?? 'Failed to follow');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _performSearch,
            decoration: const InputDecoration(
              hintText: 'Search profiles...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search results header
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
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
                ? const Center(child: CircularProgressIndicator())
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
                        const SizedBox(height: 16),
                        Text(
                          'No profiles found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom
                      if (index == _searchResults.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!,
                              ),
                            ),
                          ),
                        );
                      }

                      final user = _searchResults[index];
                      return _buildUserTile(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final userId = user['_id'] ?? user['id'] ?? '';
    final isFollowing = _followingUsers.contains(userId);

    return GestureDetector(
      onTap: () {
        // Navigate to user profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userInfo: user),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                gradient: user['profilePicture'] == null
                    ? const LinearGradient(
                        colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                image: user['profilePicture'] != null
                    ? DecorationImage(
                        image: NetworkImage(
                          ApiService.getImageUrl(user['profilePicture']),
                        ),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading errors silently
                        },
                      )
                    : null,
              ),
              child: user['profilePicture'] == null
                  ? const Icon(Icons.person, color: Colors.white, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user['displayName'] ??
                            user['username'] ??
                            'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (user['isVerified'])
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(0xFF701CF5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user['username'] ?? 'unknown'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['bio'] ?? 'No bio available',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getFollowersCount(user)} followers',
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
              onTap: () => _toggleFollow(userId, isFollowing),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isFollowing
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: isFollowing ? Colors.grey[200] : null,
                  border: isFollowing
                      ? Border.all(color: Colors.grey[400]!, width: 1)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFollowing)
                      Icon(Icons.check, size: 14, color: Colors.grey[700]),
                    if (isFollowing) const SizedBox(width: 4),
                    Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: isFollowing ? Colors.grey[700] : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getFollowersCount(Map<String, dynamic> user) {
    // Try different possible field names for followers count
    final count =
        user['followersCount'] ??
        user['followers'] ??
        user['followerCount'] ??
        user['followersLength'] ??
        0;

    // Debug followers count if needed
    // print('🔍 DEBUG - Followers count for ${user['username']}: $count');

    // Handle different data types
    if (count is int) {
      return count;
    } else if (count is double) {
      return count.toInt();
    } else if (count is String) {
      return int.tryParse(count) ?? 0;
    } else if (count is List) {
      return count.length;
    }

    return 0;
  }

  Future<void> _refreshUserData() async {
    // Refresh user data to get updated followers count
    try {
      final response = await ApiService.searchUsers('');
      if (response['success']) {
        final users = List<Map<String, dynamic>>.from(response['data'] ?? []);

        // Update existing users with fresh data
        for (int i = 0; i < _allUsers.length; i++) {
          final currentUser = _allUsers[i];
          final updatedUser = users.firstWhere(
            (u) =>
                (u['_id'] ?? u['id']) ==
                (currentUser['_id'] ?? currentUser['id']),
            orElse: () => currentUser,
          );
          _allUsers[i] = updatedUser;
        }

        // Update search results if they exist
        if (_searchResults.isNotEmpty) {
          for (int i = 0; i < _searchResults.length; i++) {
            final currentUser = _searchResults[i];
            final updatedUser = users.firstWhere(
              (u) =>
                  (u['_id'] ?? u['id']) ==
                  (currentUser['_id'] ?? currentUser['id']),
              orElse: () => currentUser,
            );
            _searchResults[i] = updatedUser;
          }
        }

        if (mounted) {
          setState(() {
            // Trigger rebuild with updated data
          });
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
