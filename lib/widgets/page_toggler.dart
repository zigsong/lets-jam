import 'package:flutter/material.dart';

class PageToggler extends StatelessWidget {
  final VoidCallback onTap;
  final int selectedIndex;

  const PageToggler(
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
              width: 160,
              decoration: BoxDecoration(
                  color: const Color(0xffefeff0),
                  borderRadius: BorderRadius.circular(25)),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: selectedIndex == 0 ? 0 : 76,
              child: Container(
                alignment: Alignment.center,
                height: 32,
                width: 84,
                decoration: BoxDecoration(
                  color: const Color(0xffffb4b4),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '밴드찾기',
                  style: TextStyle(
                      color: selectedIndex == 0
                          ? Colors.white
                          : const Color(0xffafb1b6)),
                ),
                const SizedBox(
                  width: 28,
                ),
                Text(
                  '멤버찾기',
                  style: TextStyle(
                      color: selectedIndex == 1
                          ? Colors.white
                          : const Color(0xffafb1b6)),
                ),
              ],
            )
          ],
        ),
      ),
    ]);
  }
}
