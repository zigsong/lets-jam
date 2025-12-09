import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef SettingAction = void Function();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  final SessionController sessionController = Get.find<SessionController>();

  late final settings = [
    {'title': '문의하기', 'onClick': () {}},
    {'title': '버그 제보하기', 'onClick': () {}},
    {'title': '신고하기', 'onClick': () {}},
    {'title': '서비스 이용약관', 'onClick': () {}},
    {'title': '개인정보 처리방침', 'onClick': () {}},
    {
      'title': '로그아웃',
      'onClick': () async {
        await sessionController.signOut();
        if (mounted) {
          showModal(
            context: context,
            title: '로그아웃되었어요',
            desc: 'JAM 메인으로 이동할게요',
            onConfirm: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DefaultNavigation()));
            },
          );
        }
      }
    },
    {'title': '회원 탈퇴', 'onClick': () {}},
    {
      'title': '앱 버전 정보',
      'subtitle': _version,
      'onClick': () {},
    },
  ];

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
          final onClick = item['onClick'] as SettingAction?;

          return ListTile(
            title: Row(
              children: [
                Text(
                  item['title'] as String,
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
                    item['subtitle'] as String,
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
              if (onClick != null) {
                onClick();
              }
              // Navigator.pushNamed(context, item['route']!);
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
