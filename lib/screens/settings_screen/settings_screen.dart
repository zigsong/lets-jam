import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/terms_detail_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/custom_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingItem {
  final String title;
  final String? subtitle;
  final String? info;
  final String? url;
  final VoidCallback? onClick;
  final bool showArrow;
  final Color? textColor;
  final Color? arrowColor;
  final FontWeight? titleFontWeight;

  const SettingItem({
    required this.title,
    this.subtitle,
    this.info,
    this.url,
    this.onClick,
    this.showArrow = true,
    this.textColor,
    this.arrowColor,
    this.titleFontWeight,
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
  late Worker _loginWorker;

  List<SettingItem> get settings => [
        if (!sessionController.isLoggedIn.value)
          SettingItem(
            title: '로그인/회원가입하기',
            subtitle: '로그인하고 JAM의 기능을 모두 즐겨보세요!',
            textColor: ColorSeed.boldOrangeStrong.color,
            arrowColor: ColorSeed.boldOrangeStrong.color,
            titleFontWeight: FontWeight.w700,
            onClick: () async {
              await sessionController.signIn();
            },
          ),
        const SettingItem(
          title: '문의하기',
          url: 'https://forms.gle/6JcnqBmy8Aaim5qv6',
        ),
        const SettingItem(
          title: '버그 제보하기',
          url: 'https://forms.gle/9MV6DvcKfCKQTxbXA',
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
        if (sessionController.isLoggedIn.value)
          SettingItem(
            title: '로그아웃',
            onClick: () async {
              await sessionController.signOut();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackbar(content: '로그아웃되었어요'),
                );
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DefaultNavigation()));
              }
            },
          ),
        // TODO: 어딘가로 연결 혹은 알럿
        const SettingItem(
          title: '회원 탈퇴',
        ),
        SettingItem(
          title: '앱 버전 정보',
          info: _version,
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
    _loginWorker = ever(sessionController.isLoggedIn, (bool loggedIn) {
      if (loggedIn && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _loginWorker.dispose();
    super.dispose();
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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: item.titleFontWeight ?? FontWeight.w500,
                            color: item.textColor,
                          ),
                        ),
                        if (item.info != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            item.info!,
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorSeed.meticulousGrayMedium.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.textColor != null
                              ? item.textColor!.withOpacity(0.7)
                              : ColorSeed.meticulousGrayMedium.color,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: item.showArrow
                    ? Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: item.arrowColor ??
                            ColorSeed.organizedBlackLight.color,
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
