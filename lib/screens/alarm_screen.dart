import 'package:flutter/material.dart';

import 'package:lets_jam/utils/color_seed_enum.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '알림',
            style: TextStyle(fontSize: 20),
          ),
          bottom: TabBar(
            labelColor: ColorSeed.boldOrangeMedium.color,
            unselectedLabelColor: ColorSeed.meticulousGrayMedium.color,
            indicatorColor: ColorSeed.boldOrangeMedium.color,
            indicatorWeight: 2.0,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                text: '공지',
              ),
              Tab(
                text: '알림',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.separated(
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
            const Center(
              child: Text('알림'),
            ),
          ],
        ),
      ),
    );
  }
}
