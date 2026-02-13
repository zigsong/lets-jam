import 'package:flutter/material.dart';
import 'package:lets_jam/screens/upload_screen/post_form_screen.dart';

class UploadPostScreen extends StatelessWidget {
  const UploadPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PostFormScreen(mode: PostFormMode.create);
  }
}
