import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

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
      this.maxLength,
      this.isRequired,
      this.controller,
      this.suffixButton,
      this.focusNode,
      this.errorText,
      this.prefixText,
      this.onTap});

  final String? label;
  final String? initialValue;
  final String? placeholder;
  final void Function(String)? onChanged;
  final void Function()? onSubmit;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double? height;
  final int? maxLength;
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
        if (label != null) _buildLabel(),
        Padding(
          padding: EdgeInsets.only(top: label != null ? 8 : 0),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                _buildField(),
                if (suffixButton != null) _buildSuffixButton(context),
              ],
            ),
          ),
        ),
        if (errorText != null) _buildErrorText(),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label!,
          style: TextStyle(
              fontSize: 13, color: ColorSeed.organizedBlackMedium.color),
        ),
        const SizedBox(width: 2),
        if (isRequired == true)
          Text('*', style: TextStyle(color: ColorSeed.boldOrangeStrong.color)),
      ],
    );
  }

  Widget _buildField() {
    final border = OutlineInputBorder(
      borderSide:
          BorderSide(color: ColorSeed.meticulousGrayLight.color, width: 1),
      borderRadius: BorderRadius.circular(6),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      maxLines: keyboardType == TextInputType.multiline ? null : 1,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        prefixText: prefixText,
        hintText: placeholder,
        focusedBorder: border,
        enabledBorder: border,
        contentPadding: EdgeInsets.only(
          left: 16,
          top: 10,
          bottom: 10,
          right: suffixButton != null ? 48 : 16,
        ),
      ),
      cursorColor: ColorSeed.meticulousGrayLight.color,
      validator: validator,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: (_) => onSubmit?.call(),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _buildSuffixButton(BuildContext context) {
    return Positioned(
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
    );
  }

  Widget _buildErrorText() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          SizedBox(
              width: 13.5,
              height: 13.5,
              child: Image.asset('assets/icons/info.png')),
          const SizedBox(width: 7),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
