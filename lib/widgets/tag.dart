import 'package:flutter/material.dart';

enum TagSizeEnum { small, medium }

class Tag extends StatelessWidget {
  final String text;
  final TagSizeEnum? size;
  final Color? fgColor;
  final Color? bgColor;

  const Tag(
      {super.key,
      required this.text,
      this.size = TagSizeEnum.medium,
      this.fgColor,
      this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size == TagSizeEnum.small ? 8 : 12,
          vertical: size == TagSizeEnum.small ? 2 : 4),
      decoration: BoxDecoration(
          color: bgColor ?? const Color(0xffffb4b4),
          borderRadius: BorderRadius.circular(25)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: size == TagSizeEnum.small ? 12 : 14,
              color: fgColor ?? Colors.black),
        ),
      ),
    );
  }
}
