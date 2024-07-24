import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 500,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: "포스팅 작성...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 20)),
                  onChanged: (text) {},
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[100]),
                  onPressed: () {},
                  child: Center(
                      child: Text(
                    '완료',
                    style: TextStyle(
                        color: Colors.amber[700], fontWeight: FontWeight.bold),
                  ))),

              // const SizedBox(
              //   height: 60,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
