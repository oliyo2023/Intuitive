import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../services/supabase_service.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _videoUrl;

  @override
  void dispose() {
    _controller?.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateVideo() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _videoUrl = null;
      _controller?.dispose();
      _controller = null;
    });

    try {
      final token = ref.read(supabaseServiceProvider).supabase.auth.currentSession?.accessToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${Environment.backendUrl}/api/generate-video'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': _promptController.text.trim()}),
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        if (apiResponse['code'] == 200) {
          final videoUrl = apiResponse['data']['videoUrl'] as String?;
          if (videoUrl != null) {
            setState(() {
              _videoUrl = videoUrl;
            });
            _initializePlayer(_videoUrl!);
          }
        } else {
          // Handle backend logic error
        }
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _initializePlayer(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
        _controller?.setLooping(true);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 视频生成'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: '描述你想要生成的视频...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateVideo,
              child: _isGenerating
                  ? const CircularProgressIndicator()
                  : const Text('生成视频'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _buildVideoPlayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isGenerating) {
      return const CircularProgressIndicator();
    }
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }
    return const Text('输入描述，生成你的专属视频');
  }
}