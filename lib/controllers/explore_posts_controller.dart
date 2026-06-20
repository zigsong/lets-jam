import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 탐색 화면의 게시글을 한 번만 조회해서 두 탭(밴드/멤버)이 공유한다.
/// 기존에는 탭마다 ExplorePosts가 전체 게시글을 각각 fetch 해 중복 요청이 발생했다.
class ExplorePostsController extends GetxController {
  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      hasError.value = false;

      final currentUserId = sessionController.user.value?.id;

      List<String> blockedIds = [];
      if (currentUserId != null) {
        final blockedResponse = await supabase
            .from('blocked_users')
            .select('blocked_id')
            .eq('blocker_id', currentUserId);
        blockedIds = blockedResponse
            .map<String>((row) => row['blocked_id'] as String)
            .toList();
      }

      final query =
          supabase.from('posts').select('*, comment_count:comments!left(id)');

      final response = blockedIds.isNotEmpty
          ? await query
              .not('user_id', 'in', blockedIds)
              .order('created_at', ascending: false)
          : await query.order('created_at', ascending: false);

      posts.assignAll(
          response.map<PostModel>((json) => PostModel.fromJson(json)).toList());
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
