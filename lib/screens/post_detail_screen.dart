import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/image_slider.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserById();
  }

  Future<void> _fetchUserById() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('id', widget.post.userId)
          .single();

      setState(() {
        _user = UserModel.fromJson(response);
      });
    } catch (error) {
      print('포스팅 유저 가져오기 에러 : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              ImageSlider(images: widget.post.images),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (_user != null) PostDetailAuthorInfo(user: _user!),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.post.postType == PostTypeEnum.findBand)
                      WantedSession(post: widget.post),
                    const SizedBox(
                      height: 10,
                    ),
                    PostDetailInfo(post: widget.post),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(widget.post.description),
                    )
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 뒤로 가기
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: widget.post.postType == PostTypeEnum.findSession
                ? Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xffBFFFAF),
                            foregroundColor: const Color(0xff1c1c1c),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xffD9D9D9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    /** TODO: 밴드 프로필로 연결 */
                                    '원 투 ASDF',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    'since 2022',
                                    style: TextStyle(color: Color(0xff4E4E4E)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xff1c1c1c),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset('assets/icons/mail.svg'),
                              const Text(
                                '문의',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : WideButton(
                    text: '세션에게 연락하기',
                    onPressed: () {},
                  ),
          )
        ],
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
            color: const Color(0xff6A6A6A),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Text(
              '밴드에서',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Row(
              children: post.sessions
                  .map((session) => sessionMap[session]!)
                  .toList()
                  .map(
                    (tag) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Tag(
                        text: tag,
                        size: TagSizeEnum.small,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(width: 4),
            const Text(
              '을(를) 담당하고 싶어요',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
          color: const Color(0xffF3F3F3),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _filterDataList(
              '레벨', post.levels.map((level) => levelMap[level]!).toList()),
          if (post.postType == PostTypeEnum.findSession)
            _filterDataList('세션',
                post.sessions.map((session) => sessionMap[session]!).toList()),
          _filterDataList(
              '연령대', post.ages?.map((age) => ageMap[age]!).toList()),
          _filterDataList('지역', post.regions),
          Row(
            children: [
              const SizedBox(
                width: 48,
                child: Text(
                  '연락처',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                child: Row(
                  children: [
                    Text(
                      post.contact,
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    const Icon(
                      Icons.content_copy,
                      size: 14,
                      color: Colors.grey,
                    )
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("연락처가 복사되었습니다")),
                  );
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _filterDataList(String label, List<String>? tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (tags != null)
            Row(
                children: tags
                    .map(
                      (tag) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Tag(
                          text: tag,
                          size: TagSizeEnum.small,
                        ),
                      ),
                    )
                    .toList())
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
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(width: 1, color: Color(0xffCACACA)),
              bottom: BorderSide(width: 1, color: Color(0xffCACACA)))),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(100)),
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
          const Icon(
            Icons.more_vert,
            color: Color(0xff606060),
          ),
        ],
      ),
    );
  }
}
