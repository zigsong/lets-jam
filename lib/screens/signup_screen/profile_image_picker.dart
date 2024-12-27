import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final Function(XFile file) onSelect;
  final XFile? profileImage;

  const ProfileImagePicker(
      {super.key, required this.onSelect, this.profileImage});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;

  _showImagePickerOptions(BuildContext context) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => Theme(
              data: ThemeData.light(),
              child: CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    child: const Text(
                      '사진에서 선택',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final XFile? file =
                          await _picker.pickImage(source: ImageSource.gallery);
                      Navigator.pop(context);
                      setState(() {
                        _selectedFile = file;
                      });
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text(
                      '카메라로 촬영',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final XFile? file =
                          await _picker.pickImage(source: ImageSource.camera);
                      Navigator.pop(context);
                      setState(() {
                        _selectedFile = file;
                      });
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                    child: const Text(
                      '취소',
                      style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                    }),
              ),
            ));
  }

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await _picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      widget.onSelect(XFile(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Container(
              width: 138,
              height: 138,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(100)),
              clipBehavior: Clip.antiAlias,
              child: widget.profileImage != null
                  ? Image.file(
                      File(widget.profileImage!.path),
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/images/avatar.png'),
            ),
            Positioned(
              right: 0,
              top: 20,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: const Color(0xffBFFFAF),
                    borderRadius: BorderRadius.circular(100)),
                child: Center(
                  child: Image.asset(
                    'assets/icons/edit.png',
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () => _showImagePickerOptions(context),
    );
  }
}
