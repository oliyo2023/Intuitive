import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';

final profileProvider = StreamProvider<Profile?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  
  // Listen to the stream from SupabaseService
  final stream = supabaseService.getProfileStream();
  
  // Map the raw map data to a Profile object
  return stream.map((data) => data != null ? Profile.fromMap(data) : null);
});