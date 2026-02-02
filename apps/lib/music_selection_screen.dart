import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'services/api_service.dart';

class MusicSelectionScreen extends StatefulWidget {
  final String selectedPath; // 'reels' or 'SYT'
  final String? category; // Category for SYT
  final Function(String? musicId, Map<String, dynamic>? music)? onMusicSelected;
  final VoidCallback? onSkip;
  final VoidCallback? onBack;

  const MusicSelectionScreen({
    super.key,
    required this.selectedPath,
    this.category,
    this.onMusicSelected,
    this.onSkip,
    this.onBack,
  });

  @override
  State<MusicSelectionScreen> createState() => _MusicSelectionScreenState();
}

class _MusicSelectionScreenState extends State<MusicSelectionScreen> {
  List<Map<String, dynamic>> _musicList = [];
  List<Map<String, dynamic>> _filteredMusicList = [];
  bool _isLoading = true;
  String? _selectedMusicId;
  String _selectedGenre = '';
  String _selectedMood = '';
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterMusic);
    _loadMusic();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMusic() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredMusicList = _musicList.where((music) {
        final title = (music['title'] ?? '').toString().toLowerCase();
        final artist = (music['artist'] ?? '').toString().toLowerCase();
        final genre = (music['genre'] ?? '').toString().toLowerCase();

        return title.contains(_searchQuery) ||
            artist.contains(_searchQuery) ||
            genre.contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _loadMusic() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final response = await ApiService.getApprovedMusic(
        genre: _selectedGenre.isEmpty ? null : _selectedGenre,
        mood: _selectedMood.isEmpty ? null : _selectedMood,
      );

      if (!mounted) return; // Check again after async operation

      if (response['success']) {
        setState(() {
          _musicList = List<Map<String, dynamic>>.from(response['data']);
          _filterMusic(); // Apply search filter
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error loading music'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading music: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading music'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _proceedWithoutMusic() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(selectedPath: widget.selectedPath),
        ),
      );
    }
  }

  void _proceedWithMusic() {
    if (_selectedMusicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a music track'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Find selected music data
    final selectedMusic = _musicList.firstWhere(
      (music) => music['_id'] == _selectedMusicId,
      orElse: () => {},
    );

    if (widget.onMusicSelected != null) {
      widget.onMusicSelected!(_selectedMusicId, selectedMusic);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            selectedPath: widget.selectedPath,
            backgroundMusicId: _selectedMusicId,
          ),
        ),
      );
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
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Select Background Music',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title, artist, or genre...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF701CF5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterMusic();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF701CF5),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Genre & Mood',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedGenre.isEmpty ? null : _selectedGenre,
                        hint: const Text('Genre'),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('All Genres'),
                          ),
                          const DropdownMenuItem(
                            value: 'pop',
                            child: Text('Pop'),
                          ),
                          const DropdownMenuItem(
                            value: 'rock',
                            child: Text('Rock'),
                          ),
                          const DropdownMenuItem(
                            value: 'jazz',
                            child: Text('Jazz'),
                          ),
                          const DropdownMenuItem(
                            value: 'classical',
                            child: Text('Classical'),
                          ),
                          const DropdownMenuItem(
                            value: 'electronic',
                            child: Text('Electronic'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGenre = value ?? '';
                          });
                          _loadMusic();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedMood.isEmpty ? null : _selectedMood,
                        hint: const Text('Mood'),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('All Moods'),
                          ),
                          const DropdownMenuItem(
                            value: 'happy',
                            child: Text('Happy'),
                          ),
                          const DropdownMenuItem(
                            value: 'sad',
                            child: Text('Sad'),
                          ),
                          const DropdownMenuItem(
                            value: 'energetic',
                            child: Text('Energetic'),
                          ),
                          const DropdownMenuItem(
                            value: 'calm',
                            child: Text('Calm'),
                          ),
                          const DropdownMenuItem(
                            value: 'romantic',
                            child: Text('Romantic'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMood = value ?? '';
                          });
                          _loadMusic();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Music List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF701CF5),
                      ),
                    ),
                  )
                : _filteredMusicList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No music found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'Try different filters',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMusicList.length,
                    itemBuilder: (context, index) {
                      final music = _filteredMusicList[index];
                      final isSelected = _selectedMusicId == music['_id'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMusicId = music['_id'];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF701CF5)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? const Color(0xFF701CF5).withValues(alpha: 0.1)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              // Selection indicator
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF701CF5)
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Color(0xFF701CF5),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Music info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      music['title'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          music['artist'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF701CF5,
                                            ).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            music['genre'] ?? 'Other',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF701CF5),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            music['mood'] ?? 'Other',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Duration
                              Text(
                                _formatDuration(music['duration'] ?? 0),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Proceed with music button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _proceedWithMusic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF701CF5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Continue with Selected Music',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Skip music button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _proceedWithoutMusic,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF701CF5),
                      side: const BorderSide(
                        color: Color(0xFF701CF5),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Skip Music',
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
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
