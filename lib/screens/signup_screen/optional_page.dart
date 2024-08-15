import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/signup_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OptionalPage extends StatefulWidget {
  final User user;
  final Function() onSubmit;
  final SignupModel signupData;

  const OptionalPage(
      {super.key,
      required this.user,
      required this.onSubmit,
      required this.signupData});

  @override
  State<OptionalPage> createState() => _OptionalPageState();
}

class _OptionalPageState extends State<OptionalPage> {
  final _formKey = GlobalKey<FormState>();
  late ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        widget.signupData.images.add(XFile(pickedFile.path));
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.onSubmit();
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
                  onSaved: (value) {
                    widget.signupData.contact = value ?? '';
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
                    ...widget.signupData.images.map((image) => Container(
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
                ),
                const SizedBox(
                  height: 16,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '자기소개',
                    textAlign: TextAlign.left,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: "소개",
                      contentPadding: EdgeInsets.symmetric(vertical: 20)),
                  onChanged: (text) {
                    setState(() {
                      widget.signupData.bio = text;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('완료'),
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('다음에 작성하기'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
