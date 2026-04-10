import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/profile_model.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_section.dart';
import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/screens/upload_screen/edit_post_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lets_jam/utils/image_utils.dart';
import 'package:lets_jam/widgets/image_slider.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:lets_jam/widgets/post_like_button.dart';
import 'package:lets_jam/widgets/tag.dart';
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

      final author = ProfileModel.fromJson(response);

      setState(() {
        isMyPost = author.id == sessionController.user.value?.id;
      });

      return author;
    } catch (error) {
      print('포스팅 유저 가져오기 에러 : $error');
      throw Error;
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
      print('포스팅 가져오기 에러 : $error');
      throw Error;
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
      print('게시글 삭제 에러 : $error');

      scaffoldMessenger.showSnackBar(customSnackbar('게시글 삭제에 실패했어요'));

      throw Error;
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
        CustomSnackbar(content: '신고가 접수되었어요. 검토 후 조치하겠습니다.'),
      );
    }
  }

  void _showReportDialog(String postId) {
    String? selectedReason;
    final reasons = ['스팸', '욕설/혐오', '음란물', '사기/허위정보', '기타'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('게시글 신고'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons
                .map((reason) => RadioListTile<String>(
                      title: Text(reason),
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (value) =>
                          setDialogState(() => selectedReason = value),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _reportPost(postId);
                    },
              child: const Text('신고'),
            ),
          ],
        ),
      ),
    );
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
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPostScreen(
                                                          post: post),
                                                ),
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
                                            onPressed: () =>
                                                _showReportDialog(post.id),
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

class WantedSession extends StatelessWidget {
  const WantedSession({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: ColorSeed.boldOrangeRegular.color),
            borderRadius: BorderRadius.circular(10)),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            const Text(
              '밴드에서',
            ),
            const SizedBox(width: 4),
            ...post.sessions
                .map((session) => sessionMap[session]!)
                .toList()
                .map(
                  (tag) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Tag(
                      text: tag,
                      color: TagColorEnum.orange,
                      selected: true,
                      size: TagSizeEnum.small,
                    ),
                  ),
                ),
            const SizedBox(width: 4),
            const Text(
              '을(를) 담당하고 싶어요',
            )
          ],
        ));
  }
}

class PostDetailInfo extends StatelessWidget {
  const PostDetailInfo({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xfff5f5f5),
          border:
              Border.all(width: 1, color: ColorSeed.meticulousGrayLight.color),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          if (post.postType == PostTypeEnum.findMember)
            _filterDataList('세션',
                post.sessions.map((session) => sessionMap[session]!).toList()),
          const SizedBox(
            height: 8,
          ),
          if (post.regions?.isNotEmpty ?? false)
            _filterDataList('지역',
                post.regions?.map((region) => region.displayName).toList()),
          const SizedBox(
            height: 8,
          ),
          if (post.tags?.isNotEmpty ?? false)
            _listHashTags('해시태그', post.tags?.map((tag) => tag).toList())
        ],
      ),
    );
  }

  Widget _filterDataList(String label, List<String>? tags) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, height: 1),
            ),
          ),
        ),
        if (tags != null)
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 4,
                  children: tags
                      .expand((tag) => [
                            Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xff7c7c7c),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              '•',
                              style: TextStyle(color: Color(0xff7c7c7c)),
                            ),
                          ])
                      .toList()
                    ..removeLast(), // 마지막 점 제거
                )),
          )
      ],
    );
  }

  Widget _listHashTags(String label, List<String>? tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: SizedBox(
              width: 48,
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, height: 1),
              ),
            ),
          ),
          if (tags != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: tags
                        .map((tag) => Text(
                              tag,
                              style: const TextStyle(
                                  color: Color(0xff7c7c7c),
                                  fontWeight: FontWeight.w500),
                            ))
                        .toList()),
              ),
            )
        ],
      ),
    );
  }
}

class PostDetailAuthorInfo extends StatelessWidget {
  const PostDetailAuthorInfo(
      {super.key, required this.user, required this.contact});

  final ProfileModel user;
  final String contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 1, color: ColorSeed.meticulousGrayLight.color),
              bottom: BorderSide(
                  width: 1, color: ColorSeed.meticulousGrayLight.color))),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(profileId: user.id),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: user.profileImage?.isNotEmpty == true
                        ? CachedNetworkImage(
                    fadeInDuration: Duration.zero,
                            imageUrl: supabaseImageUrl(user.profileImage!,
                                width: 80, quality: 80),
                            fit: BoxFit.cover,
                            memCacheWidth: 80,
                          )
                        : Image.asset('assets/images/profile_avatar.png'),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        user.sessions
                            .map((session) => sessionMap[session])
                            .join(','),
                        style: const TextStyle(color: Color(0xff838589)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSeed.boldOrangeStrong.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showModal(
                  context: context,
                  title: '연락처 복사하기',
                  cancelText: '닫기',
                  desc: Builder(
                    builder: (modalcontext) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(modalcontext).pop();
                          Clipboard.setData(ClipboardData(text: contact));
                          ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackbar(content: '연락처가 복사되었어요'),
                          );
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(contact),
                            SvgPicture.asset(
                              'assets/icons/plus_copy.svg',
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text(
                '문의하기',
              ))
        ],
      ),
    );
  }
}
