import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/profile_screen/gradient_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_upload_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
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
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionController sessionController = Get.find<SessionController>();
  final supabase = Supabase.instance.client;

  bool isMyProfile = true;

  void onClickShareCourtUrl() {
    // TODO: webview_flutter로 현재 링크 가져오기
    SharePlus.instance.share(ShareParams(text: 'JAM에서 공유하기'));
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
    final profile = sessionController.user.value;

    return (Stack(children: [
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
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(100)),
                  clipBehavior: Clip.antiAlias,
                  child: profile?.profileImage != null
                      ? Image.network(profile!.profileImage!, fit: BoxFit.cover)
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
                  Text(profile.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isMyProfile)
                      ElevatedButton(
                        onPressed: () {
                          onClickShareCourtUrl();
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
                      onPressed: () {},
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
                      const Text(
                        '가능한 세션',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            height: 18 / 13),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                          alignment:
                                              AlignmentDirectional.bottomEnd,
                                          children: [
                                            Image.asset(
                                                sessionImagesActive[session]!),
                                            Padding(
                                              padding: const EdgeInsets.only(
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
                      const Text(
                        '작성한 글',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            height: 18 / 13),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(height: 0.5, color: Colors.white),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        '준비중...',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            height: 18 / 13),
                      ),
                      // Column(
                      //   children: [
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 13.5),
                      //       child: Row(
                      //         children: [
                      //           PostTypeBadge(
                      //             postType: PostTypeEnum.findBand,
                      //           ),
                      //           SizedBox(
                      //             width: 13,
                      //           ),
                      //           Text(
                      //             '밴드가 로망인 1년차 베이시스트 구합니다...',
                      //             style: TextStyle(
                      //                 color: Colors.white, height: 13 / 18),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //     Container(height: 0.5, color: Colors.white),
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 13.5),
                      //       child: Row(
                      //         children: [
                      //           PostTypeBadge(
                      //             postType: PostTypeEnum.findMember,
                      //           ),
                      //           SizedBox(
                      //             width: 13,
                      //           ),
                      //           Text(
                      //             '두탕뛸 수 있는 밴드 구해요 열씨미 할께영',
                      //             style: TextStyle(
                      //                 color: Colors.white, height: 13 / 18),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Container(height: 0.5, color: Colors.white),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ]));
  }
}
