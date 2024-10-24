import 'package:flutter/material.dart';

enum TagSizeEnum { small, medium }

class Tag extends StatelessWidget {
  final String text;
  final TagSizeEnum? size;
  const Tag({super.key, required this.text, this.size = TagSizeEnum.medium});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size == TagSizeEnum.small ? 28 : 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xffffb4b4),
          borderRadius: BorderRadius.circular(25)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: size == TagSizeEnum.small ? 12 : 14),
        ),
      ),
    );
  }
}
