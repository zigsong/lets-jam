import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/utils/analytics.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/like_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PostLikeButtonSize = LikeButtonSize;

class PostLikeButton extends StatefulWidget {
  final String postId;
  final LikeButtonSize? size;
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
        Analytics.likePost(widget.postId);
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
    if (sessionController.user.value == null) return const SizedBox.shrink();

    return LikeButton(
      isLiked: isLiked,
      onTap: _toggleLike,
      size: widget.size,
      hasBackground: widget.hasBackground,
    );
  }
}
