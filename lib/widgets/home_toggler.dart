import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class HomeToggler extends StatelessWidget {
  final VoidCallback onTap;
  final int selectedIndex;

  const HomeToggler(
      {super.key, required this.onTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 32,
              width: 136,
              decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? ColorSeed.boldOrangeRegular.color
                      : ColorSeed.boldOrangeLight.color,
                  borderRadius: BorderRadius.circular(25)),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: selectedIndex == 0 ? 0 : 64,
              child: Container(
                alignment: Alignment.center,
                height: 32,
                width: 72,
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? Colors.white
                      : ColorSeed.boldOrangeStrong.color,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '밴드',
                  style: TextStyle(
                      color: ColorSeed.boldOrangeStrong.color,
                      fontWeight: selectedIndex == 0
                          ? FontWeight.w700
                          : FontWeight.w400),
                ),
                const SizedBox(
                  width: 44,
                ),
                Text(
                  '멤버',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: selectedIndex == 0
                          ? FontWeight.w400
                          : FontWeight.w700),
                ),
              ],
            )
          ],
        ),
      ),
    ]);
  }
}
