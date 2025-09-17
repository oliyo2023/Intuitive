import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/profile_provider.dart';
import '../services/ai_image_service.dart';
import '../services/supabase_service.dart';
import '../screens/auth_screen.dart';
import '../widgets/image_card.dart';
import '../widgets/prompt_input.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  List<Map<String, dynamic>> _generatedImages = [];
  bool _isGenerating = false;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadImages();
    });
    _supabaseService.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (session != null) {
              _loadUserImages();
            } else {
              setState(() {
                _generatedImages.clear();
              });
            }
          }
        });
      }
    });
  }

  Future<void> _checkAuthAndLoadImages() async {
    if (!_supabaseService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        }
      });
      return;
    }
    await _loadUserImages();
  }

  Future<void> _loadUserImages() async {
    final aiService = ref.read(aiImageServiceProvider);
    final images = await aiService.getUserImages();
    if (mounted) {
      setState(() {
        _generatedImages = images;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsyncValue = ref.watch(profileProvider);

    if (!_supabaseService.isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('创图神器'),
        actions: [
          profileAsyncValue.when(
            data: (profile) => profile != null
                ? _buildCreditsChip(context, profile.credits)
                : const SizedBox.shrink(),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, stack) => const Icon(Icons.error_outline),
          ),
          IconButton(
            icon: const Icon(Icons.video_call_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/video');
            },
            tooltip: 'AI 视频生成',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(supabaseServiceProvider).signOut();
            },
            tooltip: '登出',
          ),
        ],
      ),
      body: Column(
        children: [
          // Prompt Input Section
          Container(
            padding: const EdgeInsets.all(16),
            child: PromptInput(
              controller: _promptController,
              onGenerate: _generateImage,
              isGenerating: _isGenerating,
            ),
          ),
          
          // Generated Images Grid
          Expanded(
            child: _generatedImages.isEmpty
                ? _buildEmptyState()
                : _buildImageGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '开始创作你的AI图像',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '输入描述文字，让AI为你生成独特的图像',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsChip(BuildContext context, int credits) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ActionChip(
        avatar: Icon(Icons.monetization_on_outlined,
            color: Theme.of(context).colorScheme.primary),
        label: Text('$credits 次'),
        onPressed: () {
          Navigator.of(context).pushNamed('/subscription');
        },
      ),
    );
  }
  
  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: _generatedImages.length + (_isGenerating ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _generatedImages.length && _isGenerating) {
            return _buildLoadingCard();
          }
          final image = _generatedImages[index];
          return ImageCard(
            imageUrl: image['image_url'],
            onDelete: () => _confirmDelete(image['id']),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Theme.of(context).colorScheme.primary,
          size: 40,
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) return;

    final profile = ref.read(profileProvider).value;
    if (profile != null && profile.credits <= 0) {
      _showInsufficientCreditsDialog();
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final aiService = ref.read(aiImageServiceProvider);
      final imageUrl = await aiService.generateImage(_promptController.text.trim());

      if (imageUrl != null) {
        await _loadUserImages();
        _promptController.clear();
      } else {
        if (mounted) {
           final profileNow = ref.read(profileProvider).value;
           if(profileNow != null && profileNow.credits <= 0) {
              _showInsufficientCreditsDialog();
           }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成图像失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showInsufficientCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('次数已用完'),
        content: const Text('您的图片生成次数已经用完，请购买套餐以继续使用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/subscription');
            },
            child: const Text('立即充值'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String imageId) async {
    final didRequestDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图像'),
        content: const Text('你确定要永久删除这张图像吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (didRequestDelete ?? false) {
      final aiService = ref.read(aiImageServiceProvider);
      final success = await aiService.deleteImage(imageId);
      if (success) {
        _loadUserImages();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除失败')),
          );
        }
      }
    }
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}