import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PostLikeButtonSize { sm, lg }

class PostLikeButton extends StatefulWidget {
  final String postId;
  final PostLikeButtonSize? size;
  final bool? hasBackground;

  const PostLikeButton(
      {super.key, required this.postId, this.size, this.hasBackground = true});

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton> {
  final SessionController sessionController = Get.find<SessionController>();
  final supabase = Supabase.instance.client;

  bool isLiked = false;
  bool isLoading = true;
  bool _isToggling = false;

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
    if (sessionController.user.value == null) return;
    // 진행 중인 토글이 있으면 무시 (중복 탭 방지)
    if (_isToggling) return;

    final userId = sessionController.user.value!.id;
    final wasLiked = isLiked;

    // 낙관적 업데이트: 먼저 UI를 바꾸고, 실패하면 롤백
    setState(() {
      _isToggling = true;
      isLiked = !wasLiked;
    });

    try {
      if (wasLiked) {
        await supabase
            .from('post_likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', widget.postId);
      } else {
        await supabase
            .from('post_likes')
            .insert({'user_id': userId, 'post_id': widget.postId});
      }
    } catch (error) {
      debugPrint('좋아요 토글 에러: $error');
      if (mounted) {
        setState(() => isLiked = wasLiked);
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackbar(wasLiked ? '좋아요 취소에 실패했어요' : '좋아요에 실패했어요'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      } else {
        _isToggling = false;
      }
    }
  }

  /// 좋아요 여부
  Future<bool> isLikePost(String postId) async {
    if (sessionController.user.value == null) {
      return false;
    }

    final userId = sessionController.user.value!.id;

    final existing = await supabase
        .from('post_likes')
        .select()
        .eq('user_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    return existing != null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmall = widget.size == PostLikeButtonSize.sm;

    if (sessionController.user.value == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _toggleLike,
      child: Container(
        width: isSmall ? 24 : 40,
        height: isSmall ? 24 : 40,
        padding: EdgeInsets.all(isSmall ? 4 : 8),
        decoration: widget.hasBackground == true
            ? BoxDecoration(
                color: ColorSeed.organizedBlackMedium.color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6))
            : null,
        child: isLiked == true
            ? Image.asset('assets/images/like_filled.png')
            : Image.asset('assets/images/like_empty.png'),
      ),
    );
  }
}
