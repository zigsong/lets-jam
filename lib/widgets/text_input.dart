import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// TODO: 정리 필요...
class TextInput extends StatelessWidget {
  const TextInput(
      {super.key,
      this.onChanged,
      this.onSubmit,
      this.label,
      this.initialValue,
      this.placeholder,
      this.validator,
      this.keyboardType,
      this.height,
      this.isRequired,
      this.controller,
      this.suffixButton,
      this.focusNode,
      this.errorText,
      this.prefixText});

  final String? label;
  final String? initialValue;
  final String? placeholder;
  final void Function(String)? onChanged;
  final void Function()? onSubmit;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double? height;
  final bool? isRequired;
  final TextEditingController? controller;
  final Widget? suffixButton;
  final FocusNode? focusNode;
  final String? errorText;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Row(
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
          ),
        Padding(
          padding: label != null
              ? const EdgeInsets.only(top: 8)
              : const EdgeInsets.all(0),
          child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    initialValue: initialValue,
                    keyboardType: keyboardType,
                    style: const TextStyle(fontSize: 13),
                    maxLines:
                        keyboardType == TextInputType.multiline ? null : 1,
                    decoration: InputDecoration(
                      prefixText: prefixText,
                      hintText: placeholder,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorSeed.meticulousGrayLight.color,
                            width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorSeed.meticulousGrayLight.color,
                            width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: EdgeInsets.only(
                        left: 16,
                        top: 10,
                        bottom: 10,
                        right: suffixButton != null ? 48 : 16,
                      ),
                    ),
                    cursorColor: ColorSeed.meticulousGrayLight.color,
                    validator: validator,
                    onChanged: onChanged,
                    onFieldSubmitted: (value) {
                      onSubmit?.call();
                    },
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  if (suffixButton != null)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: IconButton(
                        icon: suffixButton!,
                        onPressed: () {
                          onSubmit?.call();
                          FocusScope.of(context).unfocus(); // 키보드 닫기
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                ],
              )),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 13.5,
                    height: 13.5,
                    child: Image.asset('assets/icons/info.png')),
                const SizedBox(width: 7),
                Text(
                  errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
