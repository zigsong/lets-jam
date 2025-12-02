import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    print('info: $info');

    setState(() {
      _version = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: route 변경
    final settings = [
      {'title': '문의하기', 'route': '/account'},
      {'title': '버그 제보하기', 'route': '/notifications'},
      {'title': '신고하기', 'route': '/privacy'},
      {'title': '서비스 이용약관', 'route': '/about'},
      {'title': '개인정보 처리방침', 'route': '/about'},
      {'title': '로그아웃', 'route': '/about'},
      {'title': '회원 탈퇴', 'route': '/about'},
      {
        'title': '앱 버전 정보',
        'subtitle': _version,
        'route': '/about',
        // 'trailing': false
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorSeed.boldOrangeMedium.color),
        title: Text(
          '설정',
          style:
              TextStyle(fontSize: 18, color: ColorSeed.boldOrangeMedium.color),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: settings.length,
        itemBuilder: (context, index) {
          final item = settings[index];
          return ListTile(
            title: Row(
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (item['subtitle'] != null)
                  Text(
                    item['subtitle']!,
                    style: TextStyle(
                        fontSize: 13,
                        color: ColorSeed.meticulousGrayMedium.color),
                  )
              ],
            ),
            trailing: item['title'] != '앱 버전 정보'
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: ColorSeed.organizedBlackLight.color,
                  )
                : null,
            onTap: () {
              Navigator.pushNamed(context, item['route']!);
            },
          );
        },
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFDDDDDD),
          ),
        ),
      ),
    );
  }
}
