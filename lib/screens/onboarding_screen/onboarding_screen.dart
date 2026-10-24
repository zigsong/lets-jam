import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lets_jam/main.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/completion_overlay.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/genre_step.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/onboarding_genre.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/session_step.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/text_input_step.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/welcome_step.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/nickname_validator.dart';
import 'package:lets_jam/widgets/confirm_dialog.dart';

/// [개발자 전용/목업] 앱 온보딩 플로우 프로토타입.
///
/// 순수 UI 목업이라 어떤 값도 Supabase에 저장하지 않는다.
/// 설정 > JAM 개발자 테스트 > '앱 온보딩'에서 진입한다.
///
/// - '다음에 작성할게요'를 누르면 어느 스텝에서든 온보딩을 종료하고 홈('/')으로 간다.
/// - 이전 스텝으로 돌아갈 수 있고, 1번에서 더 뒤로 가면 온보딩을 종료한다.
/// - 마지막(자기소개) 스텝에서 '확인'하면 홈 위에 '프로필 완성' 딤드 오버레이를
///   띄우고, 'JAM 시작하기'를 누르면 오버레이를 닫으며 홈으로 이동한다.
///
/// 각 스텝 UI는 `steps/` 하위 위젯으로 분리돼 있다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 환영·세션·장르·닉네임·연락처·자기소개 6개 스텝. 완료 안내는 홈 위 오버레이로 처리한다.
  static const int _totalSteps = 6;

  int _step = 0;

  // 목업 입력값 (저장하지 않음)
  final Set<SessionEnum> _sessions = {};
  final Set<Genre> _genres = {};
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // 닉네임 중복 검사: profiles.nickname 을 500ms 디바운스로 조회한다.
  Timer? _nicknameDebounce;
  String? _nicknameErrorText;

  /// 8글자 제한 안내 문구. 에러와 달리 '확인'을 막지 않는다.
  String? _nicknameLengthNotice;

  /// 8글자 초과 입력을 잘라낼 때 컨트롤러를 되돌리는 과정에서 리스너가
  /// 재진입하는 것을 막는 가드.
  bool _suppressNicknameListener = false;

  /// 카카오 로그인 계정 이름. 없으면 null → 호칭 생략.
  String? get _name {
    final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final raw = (metadata?['name'] ?? metadata?['full_name']) as String?;
    if (raw == null || raw.trim().isEmpty) return null;
    return raw.trim();
  }

  /// "{name}님" / "{nickname}님" 호칭. 이름이 없으면 빈 문자열.
  String _honorific(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return '${value.trim()}님';
  }

  @override
  void dispose() {
    _nicknameDebounce?.cancel();
    _nicknameController.dispose();
    _contactController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 닉네임 입력 변경. 최대 글자 수를 넘기면 입력을 잘라 하드 제한하고
  /// 안내를 띄운다(확인은 막지 않음).
  /// 제한 이하면 안내를 지우고 로컬 검증→중복 검사를 진행한다.
  void _onNicknameChanged(String value) {
    if (_suppressNicknameListener) return;

    if (value.length > NicknameValidator.maxLength) {
      final capped = value.substring(0, NicknameValidator.maxLength);
      _suppressNicknameListener = true;
      _nicknameController.value = TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
      _suppressNicknameListener = false;
      setState(() => _nicknameLengthNotice =
          '${NicknameValidator.maxLength}글자까지 입력할 수 있어요');
      _validateNickname(capped);
      return;
    }

    setState(() => _nicknameLengthNotice = null);
    _validateNickname(value);
  }

  /// 로컬 검증 후 통과하면 디바운스로 중복 여부를 조회한다.
  void _validateNickname(String value) {
    _nicknameDebounce?.cancel();

    final localError = NicknameValidator.localError(value);
    if (localError != null) {
      setState(() => _nicknameErrorText = localError);
      return;
    }

    setState(() => _nicknameErrorText = null);
    _nicknameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final isDuplicate = await NicknameValidator.isDuplicate(
        Supabase.instance.client,
        value,
      );
      if (!mounted) return;
      setState(() {
        _nicknameErrorText =
            isDuplicate ? NicknameValidator.duplicateMessage : null;
      });
    });
  }

  /// 스텝 전환 전 키보드를 내린다. (텍스트 입력 스텝에서 포커스가 남아
  /// 다음 스텝/오버레이 위로 키보드가 계속 떠 있는 것을 막는다.)
  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _next() {
    if (_step >= _totalSteps - 1) return;
    _dismissKeyboard();
    setState(() => _step++);
  }

  void _back() {
    _dismissKeyboard();
    if (_step == 0) {
      _exit();
      return;
    }
    setState(() => _step--);
  }

  /// 온보딩 종료 후 이전 화면(개발자 테스트)으로 복귀.
  void _exit() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// '다음에 작성할게요' → 온보딩 등 쌓인 화면을 모두 닫고 홈 탭으로 복귀.
  void _goHome() {
    _dismissKeyboard();
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// '다음에 작성하기' → 작성 중인 내용이 사라진다는 확인 알럿을 띄운다.
  /// '다음에 하기'면 온보딩을 종료하고 홈으로, '계속하기'면 알럿만 닫는다.
  void _confirmSkip() {
    _dismissKeyboard();
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: '작성 중인 내용이 있어요',
        message: '지금까지 작성한 내용은 저장되지 않아요',
        leftText: '다음에 하기',
        rightText: '계속하기',
        onLeft: () {
          Navigator.of(dialogContext).pop();
          _goHome();
        },
        onRight: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  /// 마지막 스텝(자기소개) '확인' → 완료 오버레이를 띄우고,
  /// 'JAM 시작하기'를 누르면 온보딩 등 쌓인 화면을 모두 닫고 홈 탭으로 이동한다.
  void _finishToHome() {
    _dismissKeyboard();
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => CompletionOverlay(
        onDismiss: () {
          entry.remove();
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
        },
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    // 1번(환영)만 프로그레스 바를 감춘다.
    final showProgress = _step > 0;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: ColorSeed.organizedBlackLight.color,
            ),
            onPressed: _back,
          ),
          bottom: showProgress
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4 + 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: (_step + 1) / _totalSteps,
                        minHeight: 4,
                        backgroundColor: ColorSeed.boldOrangeLight.color,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorSeed.boldOrangeStrong.color,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return WelcomeStep(onNext: _next);
      case 1:
        return SessionStep(
          name: _name,
          honorific: _honorific,
          selected: _sessions,
          onToggle: (s) => setState(() {
            _sessions.contains(s) ? _sessions.remove(s) : _sessions.add(s);
          }),
          onConfirm: _next,
          onSkip: _confirmSkip,
        );
      case 2:
        return GenreStep(
          name: _name,
          honorific: _honorific,
          selected: _genres,
          onToggle: (g) => setState(() {
            _genres.contains(g) ? _genres.remove(g) : _genres.add(g);
          }),
          onConfirm: _next,
          onSkip: _confirmSkip,
        );
      case 3:
        const title = '좋아요! 🥁\n이제 JAM에서 사용할\n닉네임을 정해주세요.';
        return TextInputStep(
          title: title,
          hintText: '닉네임',
          controller: _nicknameController,
          errorText: _nicknameErrorText,
          noticeText: _nicknameLengthNotice,
          onChanged: _onNicknameChanged,
          onConfirm: _next,
          onSkip: _confirmSkip,
        );
      case 4:
        final nickname = _nicknameController.text.trim();
        final greeting =
            nickname.isEmpty ? '거의 다 왔어요! 🙌' : '$nickname님, 거의 다 왔어요! 🙌';
        return TextInputStep(
          title: '$greeting\nJAM에서 소통할 연락처를\n입력해 주세요',
          description: '카카오톡 오픈채팅방, SNS 계정 등\n공개 가능한 연락처로 작성해 주세요.',
          hintText: '연락처',
          controller: _contactController,
          allowEmptyConfirm: true,
          onConfirm: _next,
          onSkip: _confirmSkip,
        );
      case 5:
      default:
        return TextInputStep(
          title: '마지막이에요!\n자기소개를 작성해 주세요✍️',
          description: '50자 이내로 작성해 주세요 (선택)',
          hintText: '예시)주말마다 합주하고 싶은 직장인 드러머예요 🥁',
          controller: _bioController,
          maxLines: 4,
          maxLength: 50,
          allowEmptyConfirm: true,
          // 자기소개 '확인' → 홈으로 이동 후 완료 오버레이 노출.
          onConfirm: _finishToHome,
          onSkip: _confirmSkip,
        );
    }
  }
}
