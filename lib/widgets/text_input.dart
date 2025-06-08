import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.onChange,
    this.onSubmit,
    this.label,
    this.initialValue,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.height,
    this.isRequired,
    this.controller,
    this.hasSuffixButton,
  });

  final String? label;
  final String? initialValue;
  final String? placeholder;
  final void Function(String?) onChange;
  final void Function()? onSubmit;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double? height;
  final bool? isRequired;
  final TextEditingController? controller;
  final bool? hasSuffixButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (label != null)
          Positioned(
              child: Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                    fontSize: 13, color: ColorSeed.organizedBlackMedium.color),
              ),
              const SizedBox(
                width: 2,
              ),
              Text(isRequired == true ? '*' : '',
                  style: TextStyle(color: ColorSeed.boldOrangeStrong.color))
            ],
          )),
        Padding(
          padding: label != null
              ? const EdgeInsets.only(top: 26)
              : const EdgeInsets.all(0),
          child: SizedBox(
            height: height,
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 13),
              maxLines: keyboardType == TextInputType.multiline ? null : 1,
              decoration: InputDecoration(
                  hintText: placeholder,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorSeed.meticulousGrayLight.color, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ColorSeed.meticulousGrayLight.color, width: 1),
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  suffixIcon: hasSuffixButton == true
                      ? IconButton(
                          icon: Image.asset(
                            'assets/icons/send.png',
                            width: 20,
                          ),
                          onPressed: onSubmit,
                        )
                      : null),
              cursorColor: ColorSeed.meticulousGrayLight.color,
              validator: validator,
              onChanged: onChange,
            ),
          ),
        ),
      ],
    );
  }
}
