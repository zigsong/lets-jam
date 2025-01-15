import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class MultipleImagePicker extends StatefulWidget {
  final Function(XFile file) onSelect;
  final List<XFile> images;

  const MultipleImagePicker(
      {super.key, required this.onSelect, required this.images});

  @override
  State<MultipleImagePicker> createState() => _MultipleImagePickerState();
}

class _MultipleImagePickerState extends State<MultipleImagePicker> {
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      widget.onSelect(XFile(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: const Color(0xff8F9098)),
                  borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center, // SVG를 중앙에 배치
              child: SvgPicture.asset(
                'assets/icons/plus-sm.svg',
                width: 20,
                height: 20,
              )),
          onTap: () {
            getImage(ImageSource.gallery);
          },
        ),
        const SizedBox(
          width: 2,
        ),
        Row(
          children: widget.images
              .map((image) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }
}
