import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OptionalPage extends StatefulWidget {
  const OptionalPage({super.key});

  @override
  State<OptionalPage> createState() => _OptionalPageState();
}

class _OptionalPageState extends State<OptionalPage> {
  final _formKey = GlobalKey<FormState>();

  String _phone = '';
  final List<XFile> _images = [];
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _images.add(XFile(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          '추가정보 입력',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: '연락처'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '연락처를 입력하세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _phone = value ?? '';
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '사진 및 동영상',
                    textAlign: TextAlign.left,
                  ),
                ),
                Row(
                  children: [
                    ..._images.map((image) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(4)),
                          child: Image.file(File(image.path)),
                        )),
                    GestureDetector(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Center(child: Icon(Icons.add)),
                        ),
                      ),
                      onTap: () {
                        getImage(ImageSource.gallery);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
