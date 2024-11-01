import 'package:flutter/material.dart';

class CustomForm extends StatelessWidget {
  const CustomForm(
      {super.key, required this.label, this.subTitle, this.content});

  final String label;
  final String? subTitle;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (subTitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(subTitle!,
                style: const TextStyle(color: Color(0xff8F9098), fontSize: 10)),
          ),
        if (content != null) content!,
      ],
    );
  }
}
