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
import 'package:lets_jam/widgets/util_button.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<UserModel> _author;

  @override
  void initState() {
    super.initState();
    _author = _fetchUserById();
  }

  Future<UserModel> _fetchUserById() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('id', widget.post.userId)
          .single();

      return UserModel.fromJson(response);
    } catch (error) {
      print('포스팅 유저 가져오기 에러 : $error');
      throw Error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
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
                                  return const Text('작성자 정보를 불러올 수 없습니다');
                                } else {
                                  return PostDetailAuthorInfo(
                                      user: snapshot.data!);
                                }
                              },
                            ),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(widget.post.description),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      top: 24, left: 24, right: 24, bottom: 40),
                  child: widget.post.postType == PostTypeEnum.findMember
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
              top: MediaQuery.of(context).padding.top,
              right: 20,
              child: Row(
                children: [
                  UtilButton(text: '수정', onPressed: () {}),
                  const SizedBox(
                    width: 8,
                  ),
                  UtilButton(text: '삭제', onPressed: () {}),
                ],
              )),
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
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
          color: ColorSeed.boldOrangeLight.color,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _filterDataList(
              '레벨', post.levels.map((level) => levelMap[level]!).toList()),
          if (post.postType == PostTypeEnum.findMember)
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
                  style: TextStyle(fontSize: 13, height: 1),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        post.contact,
                        softWrap: true,
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      SvgPicture.asset(
                        'assets/icons/plus_copy.svg',
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("연락처가 복사되었습니다")),
                    );
                  },
                ),
              )
            ],
          )
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
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 44,
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, height: 1),
              ),
            ),
          ),
          if (tags != null)
            Expanded(
              child: Wrap(
                  runSpacing: 8,
                  children: tags
                      .map(
                        (tag) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Tag(
                            text: tag,
                            color: TagColorEnum.black,
                            selected: true,
                            size: TagSizeEnum.small,
                          ),
                        ),
                      )
                      .toList()),
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
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: user.profileImage != null
                      ? Image.network(
                          user.profileImage.path,
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
