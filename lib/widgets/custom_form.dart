import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class CustomForm extends StatelessWidget {
  const CustomForm(
      {super.key,
      required this.label,
      this.subTitle,
      this.content,
      this.isRequired});

  final String label;
  final String? subTitle;
  final Widget? content;
  final bool? isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(label),
              const SizedBox(
                width: 2,
              ),
              Text(isRequired == true ? '*' : '',
                  style: TextStyle(color: ColorSeed.boldOrangeStrong.color))
            ],
          ),
        ),
        if (subTitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(subTitle!,
                style: const TextStyle(color: Color(0xff8F9098), fontSize: 11)),
          ),
        if (content != null) content!,
      ],
    );
  }
}
