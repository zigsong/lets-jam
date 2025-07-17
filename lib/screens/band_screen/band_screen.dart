import 'package:flutter/material.dart';
import 'package:lets_jam/screens/band_screen/gradient_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class BandScreen extends StatefulWidget {
  const BandScreen({super.key});

  @override
  State<BandScreen> createState() => _BandScreenState();
}

class _BandScreenState extends State<BandScreen> {
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
            )
          ],
        ),
      ),
    ]);
  }
}
