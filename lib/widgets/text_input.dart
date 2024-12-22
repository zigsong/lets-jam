import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput(
      {super.key,
      required this.onChange,
      this.label,
      this.placeholder,
      this.validator,
      this.keyboardType,
      this.height});

  final String? label;
  final String? placeholder;
  final void Function(String?) onChange;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (label != null)
          Positioned(
              child: Text(
            label!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
        Padding(
          padding: label != null
              ? const EdgeInsets.only(top: 24)
              : const EdgeInsets.all(0),
          child: SizedBox(
            height: height ?? 44,
            child: TextFormField(
              keyboardType: keyboardType,
              minLines: keyboardType == TextInputType.multiline ? 5 : 1,
              maxLines: keyboardType == TextInputType.multiline ? null : 1,
              decoration: InputDecoration(
                  hintText: placeholder,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xffAED3FF), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xffAED3FF), width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              cursorColor: const Color(0xffAED3FF),
              validator: validator,
              onChanged: onChange,
            ),
          ),
        ),
      ],
    );
  }
}
