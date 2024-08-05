import 'package:flutter/material.dart';

class OptionalPage extends StatefulWidget {
  const OptionalPage({super.key});

  @override
  State<OptionalPage> createState() => _OptionalPageState();
}

class _OptionalPageState extends State<OptionalPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('옵셔널 정보 입력')));
  }
}
