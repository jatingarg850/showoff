import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'services/api_service.dart';

class MusicSelectionScreen extends StatefulWidget {
  final String selectedPath; // 'reels' or 'SYT'
  final String? category; // Category for SYT

  const MusicSelectionScreen({
    super.key,
    required this.selectedPath,
    this.category,
  });

  @override
  State<MusicSelectionScreen> createState() => _MusicSelectionScreenState();
}

class _MusicSelectionScreenState extends State<MusicSelectionScreen> {
  List<Map<String, dynamic>> _musicList = [];
  bool _isLoading = true;
  String? _selectedMusicId;
  String _selectedGenre = '';
  String _selectedMood = '';

  @override
  void initState() {
    super.initState();
    _loadMusic();
  }

  Future<void> _loadMusic() async {
    try {
      setState(() => _isLoading = true);

      final response = await ApiService.getApprovedMusic(
        genre: _selectedGenre.isEmpty ? null : _selectedGenre,
        mood: _selectedMood.isEmpty ? null : _selectedMood,
      );

      if (response['success']) {
        setState(() {
          _musicList = List<Map<String, dynamic>>.from(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading music'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error loading music: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading music'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proceedWithoutMusic() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(selectedPath: widget.selectedPath),
      ),
    );
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
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
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
                : _musicList.isEmpty
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
                          'No music available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try different filters',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _musicList.length,
                    itemBuilder: (context, index) {
                      final music = _musicList[index];
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
