import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import 'package:flutter/foundation.dart';

// Provider for Supabase Service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {
  SupabaseClient get supabase => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  }
  
  // 用户认证相关
  User? get currentUser => supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // 监听认证状态变化
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
  
  // 登录
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // 注册
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  // 登出
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
  
  // 上传图片到存储
  Future<String> uploadImage(String filePath, Uint8List fileBytes) async {
    final fileName = 'generated_images/${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
    
    await supabase.storage
        .from('ai-images')
        .uploadBinary(fileName, fileBytes);
    
    return supabase.storage
        .from('ai-images')
        .getPublicUrl(fileName);
  }
  
  // 保存生成记录到数据库
  Future<void> saveGeneratedImage({
    required String prompt,
    required String imageUrl,
    required String userId,
  }) async {
    await supabase.from('generated_images').insert({
      'user_id': userId,
      'prompt': prompt,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  // 获取用户的生成历史
  Future<List<Map<String, dynamic>>> getUserGeneratedImages(String userId) async {
    final response = await supabase
        .from('generated_images')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // 删除生成记录
  Future<void> deleteGeneratedImage(int imageId) async {
    await supabase
        .from('generated_images')
        .delete()
        .eq('id', imageId);
  }

  // 创建必要的数据库表和存储桶
  Future<void> setupDatabase() async {
    try {
      // 创建存储桶（如果不存在）
      await supabase.storage.createBucket('ai-images',
        const BucketOptions(public: true));
    } catch (e) {
      // 存储桶可能已存在，忽略错误
      debugPrint('Storage bucket setup: $e');
    }
  }

  // 获取用户 Profile 的 Stream
  Stream<Map<String, dynamic>?> getProfileStream() {
    final userId = currentUser?.id;
    if (userId == null) return Stream.value(null);
    return supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((maps) => maps.isNotEmpty ? maps.first : null);
  }
}