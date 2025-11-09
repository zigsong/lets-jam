import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/upload_screen/post_form_screen.dart';

class EditPostScreen extends StatelessWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return PostFormScreen(mode: PostFormMode.edit, post: post);
  }
}
