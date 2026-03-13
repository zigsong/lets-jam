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
          style:
              TextStyle(fontSize: 18, color: ColorSeed.boldOrangeMedium.color),
        ),
      ),
      body: ListView.separated(
        itemCount: 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: const Text('JAM에 오신 걸 환영해요!'),
              subtitle: const Text('JAM에서 함께 음악을 할 밴드와 멤버를 구해보세요 :)'),
              onTap: () {},
            );
          }
          return ListTile(
            title: const Text('앱 업데이트 안내 2026ver.'),
            subtitle: const Text('11.01 버전'),
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
