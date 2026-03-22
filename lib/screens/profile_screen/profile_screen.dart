import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/profile_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/profile_screen/gradient_screen.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_upload_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lets_jam/utils/image_utils.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<SessionEnum, String> sessionImagesActive = {
  SessionEnum.vocalM: 'assets/images/session_selector/vocal_m_active.png',
  SessionEnum.vocalF: 'assets/images/session_selector/vocal_fm_active.png',
  SessionEnum.drum: 'assets/images/session_selector/drum_active.png',
  SessionEnum.keyboard: 'assets/images/session_selector/keyboard_active.png',
  SessionEnum.bass: 'assets/images/session_selector/bass_active.png',
  SessionEnum.guitar: 'assets/images/session_selector/guitar_active.png',
};

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.profileId});

  final String? profileId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionController sessionController = Get.find<SessionController>();
  final supabase = Supabase.instance.client;

  ProfileModel? _targetUser;

  ProfileModel? get profile => _targetUser ?? sessionController.user.value;

  bool get isMyProfile =>
      _targetUser == null ||
      _targetUser?.id == sessionController.user.value?.id;

  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadTargetUser().then((_) => _loadPosts());
  }

  Future<void> _loadTargetUser() async {
    final profileId = widget.profileId;
    if (profileId == null) return;

    final currentUserId = sessionController.user.value?.id;
    if (profileId == currentUserId) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', profileId)
        .maybeSingle();

    if (response != null && mounted) {
      setState(() {
        _targetUser = ProfileModel.fromJson(response);
      });
    }
  }

  Future<void> _loadPosts() async {
    final userId = profile?.id;
    if (userId == null) return;
    final response = await supabase
        .from('posts')
        .select('id, post_type, title')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    if (mounted) {
      setState(() {
        _posts = List<Map<String, dynamic>>.from(response);
      });
    }
  }

  void onClickShareCourtUrl() async {
    try {
      final url = 'https://letsjam.work/profiles/${profile?.id}';
      final box = context.findRenderObject() as RenderBox;
      await SharePlus.instance.share(ShareParams(
          uri: Uri.parse(url),
          subject: 'JAM! 째미난 밴드 라이프 커뮤니티 | ${profile?.nickname}님의 프로필',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(customSnackbar('공유 오류: $e'));
      }
    }
  }

  Future<void> _deleteProfile(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await supabase.from('profiles').delete().eq('id', id);
      await sessionController.loadUser();

      scaffoldMessenger.showSnackBar(customSnackbar("프로필을 삭제했어요"));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DefaultNavigation()));
    } catch (error) {
      print('프로필 삭제 에러 : $error');
      scaffoldMessenger.showSnackBar(customSnackbar('프로필 삭제에 실패했어요'));
      throw Error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          GradientSplitScreen(
            backgroundImageUrl: profile?.backgroundImages?.isNotEmpty == true
                ? profile!.backgroundImages!.first
                : null,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 240),
                child: Column(
                  children: [
                    Container(
                      width: 102,
                      height: 102,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100)),
                      clipBehavior: Clip.antiAlias,
                      child: profile?.profileImage?.isNotEmpty == true
                          ? CachedNetworkImage(
                              fadeInDuration: Duration.zero,
                              imageUrl: supabaseImageUrl(profile!.profileImage!,
                                  width: 200, quality: 80),
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                            )
                          : Image.asset('assets/images/profile_avatar.png'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      profile?.nickname ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (profile?.bio != null && profile!.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(profile!.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isMyProfile)
                          ElevatedButton(
                            onPressed: () {
                              final contact = profile?.contact ?? '';
                              showModal(
                                context: context,
                                title: '연락처 복사하기',
                                cancelText: '닫기',
                                desc: Builder(
                                  builder: (modalContext) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(modalContext).pop();
                                        Clipboard.setData(
                                            ClipboardData(text: contact));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          CustomSnackbar(
                                              content: '연락처가 복사되었어요'),
                                        );
                                      },
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 25),
                              minimumSize: const Size(0, 35),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: ColorSeed
                                      .boldOrangeStrong.color), // 테두리 색 & 두께
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '연락하기',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: ColorSeed.boldOrangeStrong.color),
                            ),
                          ),
                        if (!isMyProfile)
                          const SizedBox(
                            width: 10,
                          ),
                        ElevatedButton(
                          onPressed: () {
                            onClickShareCourtUrl();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 25),
                            minimumSize: const Size(0, 35),
                            elevation: 0,
                            backgroundColor: ColorSeed.boldOrangeStrong.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '공유하기',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
                        if (isMyProfile) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfileUploadScreen(profile: profile),
                                ),
                              );
                              if (result == true) {
                                setState(() {});
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    customSnackbar('프로필을 수정했습니다'),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorSeed.boldOrangeStrong.color),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/edit_orange.png',
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showModal(
                                  context: context,
                                  title: '프로필을 삭제할까요?',
                                  desc: '프로필이 없으면 글과 댓글을 쓸 수 없어요',
                                  confirmText: '삭제',
                                  onConfirm: () {
                                    _deleteProfile(profile!.id);
                                  },
                                  cancelText: '취소',
                                  onCancel: null);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorSeed.boldOrangeStrong.color),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/delete_orange.png',
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                '세션',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                              children: (profile?.sessions ?? [])
                                  .map((session) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Container(
                                        width: 69,
                                        height: 69,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                              alignment: AlignmentDirectional
                                                  .bottomEnd,
                                              children: [
                                                Image.asset(sessionImagesActive[
                                                    session]!),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8, bottom: 8),
                                                  child: Text(
                                                    sessionMap[session]!,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      )))
                                  .toList()),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                '작성한 글 (${_posts.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_posts.isEmpty)
                            const Text(
                              '아직 작성한 글이 없어요',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ..._posts.asMap().entries.map((entry) {
                            final i = entry.key;
                            final post = entry.value;
                            final isband = post['post_type'] == 'findBand';
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PostDetailScreen(
                                          postId: post['id'],
                                          userId: profile!.id,
                                        ),
                                      ),
                                    ).then((_) => _loadPosts());
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 48,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 13.5, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isband ? '밴드' : '멤버',
                                            style: TextStyle(
                                                color: ColorSeed
                                                    .organizedBlackMedium.color,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                height: 1),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            post['title'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        const Icon(Icons.arrow_forward_ios,
                                            color: Colors.white, size: 12),
                                      ],
                                    ),
                                  ),
                                ),
                                if (i < _posts.length - 1)
                                  const SizedBox(height: 16),
                              ],
                            );
                          }),
                          const SizedBox(height: 64),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ]));
  }
}
