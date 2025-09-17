import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../config/env.dart';
import 'supabase_service.dart';

// Provider for AI Image Service
final aiImageServiceProvider = Provider<AIImageService>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return AIImageService(supabaseService);
});

class AIImageService {
  final SupabaseService _supabaseService;
  final _uuid = const Uuid();

  AIImageService(this._supabaseService);

  /// Generates an image by calling the backend service.
  Future<String?> generateImage(String prompt) async {
    try {
      final token = _supabaseService.supabase.auth.currentSession?.accessToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${Environment.backendUrl}/api/generate-image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        if (apiResponse['code'] == 200) {
          return apiResponse['data']['imageUrl'] as String?;
        } else {
          debugPrint('Backend logic error: ${apiResponse['msg']}');
          throw Exception('Backend error: ${apiResponse['msg']}');
        }
      } else {
        debugPrint('Failed to generate image. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating image: $e');
      return null;
    }
  }

  /// Fetches the user's generated image history.
  Future<List<Map<String, dynamic>>> getUserImages() async {
    try {
      final userId = _supabaseService.supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabaseService.supabase
          .from('generated_images')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching user images: $e');
      return [];
    }
  }

  /// Fetches all public images for the gallery.
  Future<List<Map<String, dynamic>>> getPublicImages({int limit = 20}) async {
    try {
      final response = await _supabaseService.supabase
          .from('generated_images')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching public images: $e');
      return [];
    }
  }

  /// Deletes an image record and its file from storage.
  Future<bool> deleteImage(String imageId) async {
    try {
      // First, get the image_url to delete from storage
      final response = await _supabaseService.supabase
          .from('generated_images')
          .select('image_url')
          .eq('id', imageId)
          .single();

      final imageUrl = response['image_url'] as String?;
      
      // Delete record from the database
      await _supabaseService.supabase
          .from('generated_images')
          .delete()
          .eq('id', imageId);

      // If we have a URL, delete from storage
      if (imageUrl != null) {
        final uri = Uri.parse(imageUrl);
        final pathIndex = uri.pathSegments.indexOf('public');
        if (pathIndex != -1 && uri.pathSegments.length > pathIndex + 2) {
            // Path is like /storage/v1/object/public/ai-images/generated_images/uuid.png
            // We need "generated_images/uuid.png"
            final filePath = uri.pathSegments.sublist(pathIndex + 2).join('/');
            await _supabaseService.supabase.storage
                .from('ai-images')
                .remove([filePath]);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}