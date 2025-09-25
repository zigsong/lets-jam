import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_section.dart';
import 'package:lets_jam/screens/upload_screen/edit_post_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/image_slider.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:lets_jam/widgets/post_like_button.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/util_button.dart';
import 'package:lets_jam/widgets/wide_button.dart';
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
  late Future<UserModel> _author;

  bool? isMyPost;
  bool _scrolledPastThreshold = false;

  @override
  void initState() {
    super.initState();
    _author = _fetchUserById();
    _post = _fetchPost();
  }

  Future<UserModel> _fetchUserById() async {
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('id', widget.userId)
          .single();

      final author = UserModel.fromJson(response);

      setState(() {
        isMyPost = author == sessionController.user.value;
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
    try {
      await supabase.from('posts').delete().eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(customSnackbar("게시글이 삭제되었어요"));
      Navigator.pop(context, true);
    } catch (error) {
      print('게시글 삭제 에러 : $error');

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('게시글 삭제에 실패했어요'));

      throw Error;
    }
  }

  void _refresh() {
    setState(() {
      _post = _fetchPost();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
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
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          return const Text(
                                              '작성자 정보를 불러올 수 없습니다');
                                        } else {
                                          return PostDetailAuthorInfo(
                                              user: snapshot.data!);
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
                            ],
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 24, left: 24, right: 24, bottom: 40),
                          child: post.postType == PostTypeEnum.findMember
                              ? WideButton(
                                  text: '문의하기',
                                  onPressed: () {},
                                )
                              : WideButton(
                                  text: '세션에게 연락하기',
                                  onPressed: () {},
                                ))
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
                                                title: '게시글 삭제',
                                                desc:
                                                    '삭제된 게시글과 댓글은 확인이 어려워요.\n정말 삭제할까요?',
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
                                    padding: const EdgeInsets.only(right: 27),
                                    child: PostLikeButton(
                                      postId: post.id,
                                      hasBackground: !_scrolledPastThreshold,
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
          _filterDataList(
              '지역', post.regions?.map((region) => region.name).toList()),
          _filterDataList('해시태그', post.tags?.map((tag) => tag).toList())
        ],
      ),
    );
  }

  Widget _filterDataList(String label, List<String>? tags) {
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
                              "#$tag",
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
  const PostDetailAuthorInfo({super.key, required this.user});

  final UserModel user;

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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: user.profileImage != null
                      ? Image.network(
                          user.profileImage!.path,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
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
          )
        ],
      ),
    );
  }
}
