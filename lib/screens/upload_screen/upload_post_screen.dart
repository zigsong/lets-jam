import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/upload_screen/post_form_screen.dart';

class UploadPostScreen extends StatelessWidget {
  final PostTypeEnum? postType;

  const UploadPostScreen({super.key, this.postType});

  @override
  Widget build(BuildContext context) {
    return PostFormScreen(mode: PostFormMode.create, initialPostType: postType);
  }
}
