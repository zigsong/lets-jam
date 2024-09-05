import 'package:flutter/material.dart';

class FilterTag extends StatelessWidget {
  final String text;
  const FilterTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xffffb4b4),
          borderRadius: BorderRadius.circular(25)),
      child: Text(text),
    );
  }
}
