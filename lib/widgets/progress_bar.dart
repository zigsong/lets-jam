import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double percent;
  const ProgressBar({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xffE8E9F1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 88) * percent,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xff006FFD),
            borderRadius: BorderRadius.circular(4),
          ),
        )
      ],
    );
  }
}
