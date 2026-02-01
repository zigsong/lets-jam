import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/terms_detail_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingItem {
  final String title;
  final String? subtitle;
  final String? url;
  final VoidCallback? onClick;
  final bool showArrow;

  const SettingItem({
    required this.title,
    this.subtitle,
    this.url,
    this.onClick,
    this.showArrow = true,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  final SessionController sessionController = Get.find<SessionController>();

  List<SettingItem> get settings => [
        const SettingItem(
          title: '문의하기',
          url: 'https://forms.gle/6JcnqBmy8Aaim5qv6',
        ),
        const SettingItem(
          title: '버그 제보하기',
          url: 'forms.gle/9MV6DvcKfCKQTxbXA',
        ),
        const SettingItem(
          title: '신고하기',
          url: 'https://forms.gle/bim3Q77MpJZY8X6h6',
        ),
        SettingItem(
          title: '서비스 이용약관',
          onClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TermsDetailScreen(type: TermsType.termsOfService),
              ),
            );
          },
        ),
        SettingItem(
          title: '개인정보 처리방침',
          onClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TermsDetailScreen(type: TermsType.privacyPolicy),
              ),
            );
          },
        ),
        SettingItem(
          title: sessionController.isLoggedIn.value ? '로그아웃' : '로그인',
          onClick: () async {
            if (sessionController.isLoggedIn.value) {
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
            } else {
              await sessionController.signIn();
            }
          },
        ),
        // TODO: 어딘가로 연결 혹은 알럿
        const SettingItem(
          title: '회원 탈퇴',
        ),
        SettingItem(
          title: '앱 버전 정보',
          subtitle: _version,
          showArrow: false,
        ),
      ];

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
      body: Obx(() => ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: settings.length,
            itemBuilder: (context, index) {
              final item = settings[index];

              return ListTile(
                title: Row(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                            fontSize: 13,
                            color: ColorSeed.meticulousGrayMedium.color),
                      )
                  ],
                ),
                trailing: item.showArrow
                    ? Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: ColorSeed.organizedBlackLight.color,
                      )
                    : null,
                onTap: () {
                  if (item.url != null) {
                    _launchUrl(item.url!);
                  } else if (item.onClick != null) {
                    item.onClick!();
                  }
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
          )),
    );
  }
}
