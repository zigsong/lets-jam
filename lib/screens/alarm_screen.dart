import 'package:flutter/material.dart';

import 'package:lets_jam/utils/color_seed_enum.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorSeed.boldOrangeMedium.color),
        title: Text(
          '알림',
          style: TextStyle(
              fontSize: 18, color: ColorSeed.boldOrangeMedium.color),
        ),
      ),
      body: ListView.separated(
        itemCount: 1,
        itemBuilder: (context, index) {
          return ListTile(
            title: const Text('JAM에 오신 걸 환영해요!'),
            subtitle: const Text('JAM에서 함께 음악을 할 어쩌구'),
            onTap: () {},
          );
        },
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: ColorSeed.meticulousGrayLight.color,
            thickness: 1,
            height: 1,
          ),
        ),
      ),
    );
  }
}
