import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/profile_model.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_section.dart';
import 'package:lets_jam/screens/post_detail_screen/widgets/post_detail_author_info.dart';
import 'package:lets_jam/screens/post_detail_screen/widgets/post_detail_info.dart';
import 'package:lets_jam/screens/post_detail_screen/widgets/report_dialog.dart';
import 'package:lets_jam/screens/post_detail_screen/widgets/wanted_session.dart';
import 'package:lets_jam/screens/upload_screen/edit_post_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/utils/navigation.dart';
import 'package:lets_jam/widgets/image_slider.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:lets_jam/widgets/post_like_button.dart';
import 'package:lets_jam/widgets/util_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen(
      {super.key, required this.postId, required this.userId});

  final String postId;
  final String userId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final supabase = Supabase.instance.client;
  late Future<PostModel> _post;

  final SessionController sessionController = Get.find<SessionController>();
  late Future<ProfileModel> _author;

  bool? isMyPost;
  bool _scrolledPastThreshold = false;
  final ScrollController _scrollController = ScrollController();
  double _previousBottomInset = 0;

  @override
  void initState() {
    super.initState();
    _author = _fetchUserById();
    _author.then((author) {
      if (mounted) {
        setState(() => isMyPost = author.id == sessionController.user.value?.id);
      }
    }).catchError((_) {});
    _post = _fetchPost();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset > _previousBottomInset && _scrollController.hasClients) {
      final diff = bottomInset - _previousBottomInset;
      _scrollController.jumpTo(
        (_scrollController.offset + diff).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
      );
    }
    _previousBottomInset = bottomInset;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // 페이지 떠날 때 상태바 원래 색으로 복원
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  Future<ProfileModel> _fetchUserById() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', widget.userId)
          .single();
      return ProfileModel.fromJson(response);
    } catch (error) {
      debugPrint('포스팅 유저 가져오기 에러 : $error');
      rethrow;
    }
  }

  Future<PostModel> _fetchPost() async {
    try {
      final response = await supabase
          .from('posts')
          .select('*')
          .eq('id', widget.postId)
          .single();

      final post = PostModel.fromJson(response);

      return post;
    } catch (error) {
      debugPrint('포스팅 가져오기 에러 : $error');
      rethrow;
    }
  }

  Future<void> _deletePost(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await supabase.from('posts').delete().eq('id', id);

      scaffoldMessenger.showSnackBar(customSnackbar("게시글이 삭제되었어요"));
      navigator.pop(true);
    } catch (error) {
      debugPrint('게시글 삭제 에러 : $error');

      scaffoldMessenger.showSnackBar(customSnackbar('게시글 삭제에 실패했어요'));

      rethrow;
    }
  }

  Future<void> _reportPost(String postId) async {
    try {
      await supabase.from('reports').insert({
        'reporter_id': sessionController.user.value?.id,
        'reported_post_id': postId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar('신고가 접수되었어요'),
      );
    }
  }

  void _refresh() {
    setState(() {
      _post = _fetchPost();
    });
  }

  @override
  Widget build(BuildContext context) {
    // state가 MediaQuery를 구독하도록 강제 → didChangeDependencies가 키보드 변화에 반응함
    MediaQuery.of(context).viewInsets.bottom;
    return FutureBuilder(
        future: _post,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching post'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Post not found.'));
          }

          final post = snapshot.data!;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.axis != Axis.vertical) return false;

                final offset = notification.metrics.pixels;
                const threshold = 150.0; // threshold 설정

                if (offset > threshold && !_scrolledPastThreshold) {
                  setState(() {
                    _scrolledPastThreshold = true;
                  });
                } else if (offset <= threshold && _scrolledPastThreshold) {
                  setState(() {
                    _scrolledPastThreshold = false;
                  });
                }

                return true; // 이벤트 계속 전달되지 않게 여기서 처리 완료
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              ImageSlider(images: post.images),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          height: 26 / 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    FutureBuilder(
                                      future: _author,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox.shrink();
                                        } else if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          return const Text(
                                              '작성자 정보를 불러올 수 없습니다');
                                        } else {
                                          return PostDetailAuthorInfo(
                                              user: snapshot.data!,
                                              contact: post.contact);
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (post.postType == PostTypeEnum.findBand)
                                      WantedSession(post: post),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if ((post.postType ==
                                                PostTypeEnum.findMember &&
                                            post.sessions.isNotEmpty) ||
                                        (post.regions?.isNotEmpty ?? false) ||
                                        (post.tags?.isNotEmpty ?? false))
                                      PostDetailInfo(post: post),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(post.description),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color: ColorSeed.meticulousGrayLight.color,
                                indent: 16,
                                endIndent: 16,
                              ),
                              ReplySection(postId: post.id),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
                        decoration: _scrolledPastThreshold
                            ? const BoxDecoration(color: Colors.white)
                            : BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    ColorSeed.organizedBlackMedium.color
                                        .withOpacity(0.5),
                                    ColorSeed.organizedBlackMedium.color
                                        .withOpacity(0),
                                  ],
                                ),
                              ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: _scrolledPastThreshold
                                      ? ColorSeed.organizedBlackMedium.color
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // 뒤로 가기
                                },
                              ),
                            ),
                            isMyPost == true
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Row(
                                      children: [
                                        UtilButton(
                                            text: '수정',
                                            color: _scrolledPastThreshold
                                                ? ColorSeed
                                                    .organizedBlackMedium.color
                                                : null,
                                            onPressed: () async {
                                              final edited =
                                                  await pushScreen(
                                                context,
                                                EditPostScreen(post: post),
                                              );

                                              if (edited == true) {
                                                _refresh();
                                              }
                                            }),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        UtilButton(
                                            text: '삭제',
                                            color: _scrolledPastThreshold
                                                ? ColorSeed
                                                    .organizedBlackMedium.color
                                                : null,
                                            onPressed: () {
                                              showModal(
                                                context: context,
                                                title: '게시글을 삭제할까요?',
                                                desc:
                                                    '삭제된 글과 댓글은 확인이 어려워요.\n정말 삭제할까요?',
                                                confirmText: '삭제',
                                                onConfirm: () {
                                                  _deletePost(post.id);
                                                },
                                              );
                                            }),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (sessionController.isLoggedIn.value)
                                          IconButton(
                                            icon: Icon(
                                              Icons.flag_outlined,
                                              color: _scrolledPastThreshold
                                                  ? ColorSeed
                                                      .organizedBlackMedium
                                                      .color
                                                  : Colors.white,
                                            ),
                                            onPressed: () => showReportDialog(
                                              context,
                                              onReport: () =>
                                                  _reportPost(post.id),
                                            ),
                                          ),
                                        PostLikeButton(
                                          postId: post.id,
                                          hasBackground: false,
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        });
  }
}
