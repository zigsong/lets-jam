import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/profile_screen/gradient_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/post_type_badge.dart';
import 'package:lets_jam/widgets/util_button.dart';
import 'package:share_plus/share_plus.dart';

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
  final List<SessionEnum> mockSessions = [
    SessionEnum.vocalF,
    SessionEnum.drum,
    SessionEnum.keyboard
  ];

  void onClickShareCourtUrl() {
    // TODO: webview_flutter로 현재 링크 가져오기
    SharePlus.instance.share(ShareParams(text: 'JAM에서 공유하기'));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const GradientSplitScreen(),
      // TODO: 수정 삭제 버튼 - 내 게시글만
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: MediaQuery.of(context).padding.top + 72,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF222222), Colors.transparent],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                UtilButton(
                    text: '수정',
                    color: ColorSeed.meticulousGrayLight.color,
                    onPressed: () async {}),
                const SizedBox(
                  width: 8,
                ),
                UtilButton(
                    text: '삭제',
                    color: ColorSeed.meticulousGrayLight.color,
                    onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 60,
        left: 0,
        right: 0,
        child: Column(
          children: [
            Container(
              width: 102,
              height: 102,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(100)),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/images/profile_avatar.png'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '독창적인 딸기',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('안녕하세요! 데이식스, 터치드 좋아하는 직밴 입니다\n📞 공연문의 환영!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                )),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 96.5,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      onClickShareCourtUrl();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color:
                              ColorSeed.boldOrangeStrong.color), // 테두리 색 & 두께
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '공유하기',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: ColorSeed.boldOrangeStrong.color),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 96.5,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: ColorSeed.boldOrangeStrong.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '연락하기',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ),
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
                      children: mockSessions
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
                                      alignment: AlignmentDirectional.bottomEnd,
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
                    '작성한 글(2)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 18 / 13),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(height: 0.5, color: Colors.white),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13.5),
                        child: Row(
                          children: [
                            PostTypeBadge(
                              postType: PostTypeEnum.findBand,
                            ),
                            SizedBox(
                              width: 13,
                            ),
                            Text(
                              '밴드가 로망인 1년차 베이시스트 구합니다...',
                              style: TextStyle(
                                  color: Colors.white, height: 13 / 18),
                            )
                          ],
                        ),
                      ),
                      Container(height: 0.5, color: Colors.white),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13.5),
                        child: Row(
                          children: [
                            PostTypeBadge(
                              postType: PostTypeEnum.findMember,
                            ),
                            SizedBox(
                              width: 13,
                            ),
                            Text(
                              '두탕뛸 수 있는 밴드 구해요 열씨미 할께영',
                              style: TextStyle(
                                  color: Colors.white, height: 13 / 18),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(height: 0.5, color: Colors.white),
                ],
              ),
            )
          ],
        ),
      ),
    ]);
  }
}
