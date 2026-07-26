import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `studio_likes` 테이블(user_id, studio_id, liked_at) 접근 레이어.
/// StudioScreen(찜 토글)과 찜 목록 화면이 공유한다.
class StudioLikeService {
  StudioLikeService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

  static String? get _userId => Get.find<SessionController>().user.value?.id;

  /// 현재 유저가 찜한 합주실 id 집합.
  static Future<Set<String>> fetchLikedIds() async {
    final userId = _userId;
    if (userId == null) return {};

    final res = await _supabase
        .from('studio_likes')
        .select('studio_id')
        .eq('user_id', userId);

    return (res as List).map((row) => row['studio_id'] as String).toSet();
  }

  /// 찜한 합주실 목록 (최근 찜한 순).
  static Future<List<Studio>> fetchLikedStudios() async {
    final userId = _userId;
    if (userId == null) return [];

    final res = await _supabase
        .from('studio_likes')
        .select('studios(id, studio_name, region, rooms)')
        .eq('user_id', userId)
        .order('liked_at', ascending: false);

    return (res as List)
        .map((row) => row['studios'])
        .whereType<Map<String, dynamic>>()
        .map(Studio.fromMap)
        .toList();
  }

  /// 찜 추가.
  static Future<void> like(String studioId) async {
    final userId = _userId;
    if (userId == null) return;

    await _supabase
        .from('studio_likes')
        .insert({'user_id': userId, 'studio_id': studioId});
  }

  /// 찜 해제.
  static Future<void> unlike(String studioId) async {
    final userId = _userId;
    if (userId == null) return;

    await _supabase
        .from('studio_likes')
        .delete()
        .eq('user_id', userId)
        .eq('studio_id', studioId);
  }
}
