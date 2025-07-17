import 'package:flutter/material.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/band_screen/gradient_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

Map<SessionEnum, String> sessionImagesActive = {
  SessionEnum.vocalM: 'assets/images/session_selector/vocal_m_active.png',
  SessionEnum.vocalF: 'assets/images/session_selector/vocal_fm_active.png',
  SessionEnum.drum: 'assets/images/session_selector/drum_active.png',
  SessionEnum.keyboard: 'assets/images/session_selector/keyboard_active.png',
  SessionEnum.bass: 'assets/images/session_selector/bass_active.png',
  SessionEnum.guitar: 'assets/images/session_selector/guitar_active.png',
};

class BandScreen extends StatefulWidget {
  const BandScreen({super.key});

  @override
  State<BandScreen> createState() => _BandScreenState();
}

class _BandScreenState extends State<BandScreen> {
  final List<SessionEnum> mockSessions = [
    SessionEnum.vocalF,
    SessionEnum.drum,
    SessionEnum.keyboard
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const GradientSplitScreen(),
      Positioned(
        bottom: 80,
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
                    onPressed: () {},
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
                    style: TextStyle(color: Colors.white, height: 18 / 13),
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
                                    color: Colors.white,
                                  ),
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
                                              right: 10, bottom: 10),
                                          child: Text(
                                            sessionMap[session]!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ]),
                                ),
                              )))
                          .toList()),
                ],
              ),
            )
          ],
        ),
      ),
    ]);
  }
}
