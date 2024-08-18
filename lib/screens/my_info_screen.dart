import 'package:flutter/material.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyInfoScreen extends StatefulWidget {
  final UserModel user;

  const MyInfoScreen({super.key, required this.user});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final supabase = Supabase.instance.client;

  TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        height: 480,
        decoration: BoxDecoration(
            color: Colors.amber[500], borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.nickname,
                        style: textStyle.copyWith(
                            height: 1,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lv.${levelMap[widget.user.level]!}',
                        style: textStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 410,
                decoration: BoxDecoration(
                    color: Colors.amber[300],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    RowData(
                      label: '연령그룹',
                      content: ageMap[widget.user.age]!,
                    ),
                    RowData(
                        label: '세션',
                        content: widget.user.sessions
                            .map((session) => sessionMap[session]!)
                            .toList()
                            .join(', ')),
                    RowData(
                      label: '연락처',
                      content: widget.user.contact,
                    ),
                    RowData(
                      label: '소개',
                      content: widget.user.bio,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RowData extends StatelessWidget {
  const RowData({
    super.key,
    required this.label,
    required this.content,
  });

  final String label, content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 72,
              child: Text(
                label,
                style: const TextStyle(color: Colors.grey),
              )),
          Text(
            content,
          )
        ],
      ),
    );
  }
}
