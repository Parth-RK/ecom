import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading AssetManifest
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;
  List<String> _audioFiles = [];
  List<String> _originalOrder = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffling = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudioFiles();
    _setupStreams();
    _player.setVolume(_volume);
  }

  Future<void> _loadAudioFiles() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
      
      final audioPaths = manifestMap.keys
          .where((path) => 
              path.startsWith('assets/audio/') &&
              (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.ogg')))
          .toList();
      
      setState(() {
        _audioFiles = audioPaths;
        _originalOrder = List.from(audioPaths);
      });

      if (_audioFiles.isNotEmpty) {
        await _loadTrack(_currentIndex);
      }
    } catch (e) {
      print('Error loading audio files: $e');
    }
  }

  void _setupStreams() {
    _player.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
    
    _player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    
    _player.durationStream.listen((duration) {
      if (mounted) setState(() => _duration = duration ?? Duration.zero);
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  Future<void> _loadTrack(int index) async {
    if (_audioFiles.isEmpty) return;
    
    try {
      await _player.setAsset(_audioFiles[index]);
      await _player.setVolume(_volume);
      setState(() => _currentIndex = index);
    } catch (e) {
      print('Error loading track: $e');
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffling = !_isShuffling;
      if (_isShuffling) {
        final currentTrack = _audioFiles[_currentIndex];
        _audioFiles.shuffle();
        _currentIndex = _audioFiles.indexOf(currentTrack);
      } else {
        final currentTrack = _audioFiles[_currentIndex];
        _audioFiles = List.from(_originalOrder);
        _currentIndex = _audioFiles.indexOf(currentTrack);
      }
    });
  }

  void _playNext() async {
    if (_audioFiles.isEmpty) return;
    int nextIndex = (_currentIndex + 1) % _audioFiles.length;
    await _loadTrack(nextIndex);
    await _player.play();
  }

  void _playPrevious() async {
    if (_audioFiles.isEmpty) return;
    int prevIndex = (_currentIndex - 1 + _audioFiles.length) % _audioFiles.length;
    await _loadTrack(prevIndex);
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? screenSize.width * 0.9 : 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSmallScreen) ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _audioFiles.isNotEmpty
                      ? _audioFiles[_currentIndex].split('/').last
                      : 'No Song',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle),
                      color: _isShuffling ? Colors.indigo : Colors.grey,
                      onPressed: _toggleShuffle,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: _playPrevious,
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 56,
                      color: Colors.indigo,
                      onPressed: () async {
                        if (_isPlaying) {
                          await _player.pause();
                        } else {
                          await _player.play();
                        }
                        if (mounted) {
                          setState(() => _isPlaying = !_isPlaying);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: _playNext,
                    ),
                    IconButton(
                      icon: Icon(Icons.volume_up),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildVolumeDialog(),
                        );
                      },
                    ),
                  ],
                ),
                Slider(
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                  activeColor: Colors.indigo,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _player.seek(position);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildVolumeDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Adjust Volume', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  min: 0.0,
                  max: 1.0,
                  value: _volume,
                  onChanged: (value) async {
                    setDialogState(() => _volume = value);
                    setState(() => _volume = value);
                    await _player.setVolume(value);
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: TextStyle(color: Colors.indigo)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
