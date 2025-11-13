import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class MultipleImagePicker extends StatefulWidget {
  final Function(XFile file) onSelect;
  final List<String> images;

  const MultipleImagePicker(
      {super.key, required this.onSelect, required this.images});

  @override
  State<MultipleImagePicker> createState() => _MultipleImagePickerState();
}

class _MultipleImagePickerState extends State<MultipleImagePicker> {
  final ImagePicker picker = ImagePicker();
  int imageCount = 0;

  @override
  void initState() {
    super.initState();
    imageCount = widget.images.length;
  }

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      widget.onSelect(XFile(pickedFile.path));
    }
  }

  Widget buildImageFromString(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
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
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          'assets/icons/upload_camera.png',
                        ),
                      ),
                      Text(
                        '$imageCount/5',
                        style: TextStyle(
                            fontSize: 8,
                            color: ColorSeed.meticulousGrayMedium.color,
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  ),
                ),
              )),
          onTap: () {
            getImage(ImageSource.gallery);
            setState(() {
              imageCount = widget.images.length;
            });
          },
        ),
        const SizedBox(
          width: 8,
        ),
        Row(
          children: widget.images
              .map((image) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: buildImageFromString(image),
                      ),
                      Positioned(
                          top: 2,
                          right: 2,
                          child: Material(
                            color: Colors.transparent,
                            child: ClipOval(
                              child: InkWell(
                                onTap: () {
                                  widget.onSelect(XFile(image));
                                  setState(() {
                                    imageCount = widget.images.length;
                                  });
                                },
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: ColorSeed.meticulousGrayMedium.color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.clear_rounded,
                                    color: Colors.white,
                                    size: 10.8,
                                  ),
                                ),
                              ),
                            ),
                          ))
                    ]),
                  ))
              .toList(),
        )
      ],
    );
  }
}
