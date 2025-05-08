import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PostLikeButtonSize { sm, lg }

class PostLikeButton extends StatefulWidget {
  final String postId;
  final PostLikeButtonSize? size;

  const PostLikeButton({super.key, required this.postId, this.size});

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton> {
  final SessionController sessionController = Get.find<SessionController>();
  final supabase = Supabase.instance.client;

  bool isLiked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final result = await isLikePost(widget.postId);
    if (!mounted) return;

    setState(() {
      isLiked = result;
      isLoading = false;
    });
  }

  Future<void> _toggleLike() async {
    await toggleLikePost(widget.postId);
    await _loadLikeStatus();
  }

  /// 좋아요 여부
  Future<bool> isLikePost(String postId) async {
    if (sessionController.user.value == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    final userId = sessionController.user.value!.id;

    print('userId: $userId');
    print('postId: $postId');

    final existing = await supabase
        .from('post_likes')
        .select()
        .eq('user_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    return existing != null;
  }

  /// 좋아요 동작
  Future<void> toggleLikePost(String postId) async {
    if (sessionController.user.value == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    final userId = sessionController.user.value!.id;
    final existing = await isLikePost(postId);

    print('existing: $existing');

    try {
      await supabase
          .from('post_likes')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    } catch (error) {
      throw Exception('좋아요 취소 실패');
    }

    print('좋아요 취소됨');
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmall = widget.size == PostLikeButtonSize.sm;

    return GestureDetector(
      onTap: _toggleLike,
      child: Container(
        width: isSmall ? 24 : 40,
        height: isSmall ? 24 : 40,
        padding: EdgeInsets.all(isSmall ? 4 : 8),
        decoration: BoxDecoration(
            color: ColorSeed.organizedBlackMedium.color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6)),
        child: isLiked == true
            ? Image.asset('assets/images/like_filled.png')
            : Image.asset('assets/images/like_empty.png'),
      ),
    );
  }
}
