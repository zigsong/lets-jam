import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lets_jam/main.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/session_selector.dart';

/// [개발자 전용/목업] 앱 온보딩 플로우 프로토타입.
///
/// 순수 UI 목업이라 어떤 값도 Supabase에 저장하지 않는다.
/// 설정 > JAM 개발자 테스트 > '앱 온보딩'에서 진입한다.
///
/// - '다음에 작성할게요'를 누르면 어느 스텝에서든 온보딩을 종료하고 홈('/')으로 간다.
/// - 이전 스텝으로 돌아갈 수 있고, 1번에서 더 뒤로 가면 온보딩을 종료한다.
/// - 마지막(자기소개) 스텝에서 '확인'하면 홈 위에 '프로필 완성' 딤드 오버레이를
///   띄우고, 'JAM 시작하기'를 누르면 오버레이를 닫으며 홈으로 이동한다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// 온보딩에서만 쓰는 밴드 취향(장르). 아직 프로필 모델/DB에는 없는 목업 개념이다.
enum _Genre {
  rock,
  pop,
  rnbSoul,
  indie,
  metal,
  funk,
  kpop,
  jpop,
  cityPop,
  anime,
  etc
}

const Map<_Genre, String> _genreLabels = {
  _Genre.rock: '록',
  _Genre.pop: 'POP',
  _Genre.rnbSoul: 'R&B/소울',
  _Genre.indie: '인디',
  _Genre.metal: '메탈',
  _Genre.funk: '펑크',
  _Genre.kpop: 'K-POP',
  _Genre.jpop: 'J-POP',
  _Genre.cityPop: '시티팝',
  _Genre.anime: '애니',
  _Genre.etc: '그 외',
};

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 환영·세션·장르·닉네임·연락처·자기소개 6개 스텝. 완료 안내는 홈 위 오버레이로 처리한다.
  static const int _totalSteps = 6;

  int _step = 0;

  // 목업 입력값 (저장하지 않음)
  final Set<SessionEnum> _sessions = {};
  final Set<_Genre> _genres = {};
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // 닉네임 중복 검사: profiles.nickname 을 500ms 디바운스로 조회한다.
  Timer? _nicknameDebounce;
  String? _nicknameErrorText;

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

  /// 닉네임 입력 변경 → 디바운스 후 Supabase에서 중복 여부 조회.
  void _onNicknameChanged(String value) {
    setState(() => _nicknameErrorText = null);

    if (value.trim().isEmpty) return;

    // 8자 초과는 즉시 에러로 안내하고 중복 검사는 건너뛴다.
    if (value.trim().length > 8) {
      _nicknameDebounce?.cancel();
      setState(() => _nicknameErrorText = '닉네임은 8자까지 입력할 수 있어요');
      return;
    }

    _nicknameDebounce?.cancel();
    _nicknameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final isDuplicate = await _isNicknameDuplicate(value);
      if (!mounted) return;
      setState(() {
        _nicknameErrorText = isDuplicate ? '사용 중인 닉네임이에요.' : null;
      });
    });
  }

  Future<bool> _isNicknameDuplicate(String nickname) async {
    final result = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('nickname', nickname.trim());
    return (result as List).isNotEmpty;
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

  /// 마지막 스텝(자기소개) '확인' → 완료 오버레이를 띄우고,
  /// 'JAM 시작하기'를 누르면 온보딩 등 쌓인 화면을 모두 닫고 홈 탭으로 이동한다.
  void _finishToHome() {
    _dismissKeyboard();
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CompletionOverlay(
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
        return _WelcomeStep(onNext: _next);
      case 1:
        return _SessionStep(
          name: _name,
          honorific: _honorific,
          selected: _sessions,
          onToggle: (s) => setState(() {
            _sessions.contains(s) ? _sessions.remove(s) : _sessions.add(s);
          }),
          onConfirm: _next,
          onSkip: _goHome,
        );
      case 2:
        return _GenreStep(
          name: _name,
          honorific: _honorific,
          selected: _genres,
          onToggle: (g) => setState(() {
            _genres.contains(g) ? _genres.remove(g) : _genres.add(g);
          }),
          onConfirm: _next,
          onSkip: _goHome,
        );
      case 3:
        const title = '좋아요! 🥁\n이제 JAM에서 사용할\n닉네임을 정해주세요.';
        return _TextInputStep(
          title: title,
          hintText: '닉네임',
          controller: _nicknameController,
          errorText: _nicknameErrorText,
          onChanged: _onNicknameChanged,
          onConfirm: _next,
          onSkip: _goHome,
        );
      case 4:
        final nickname = _nicknameController.text.trim();
        final greeting =
            nickname.isEmpty ? '거의 다 왔어요! 🙌' : '$nickname님, 거의 다 왔어요! 🙌';
        return _TextInputStep(
          title: '$greeting\nJAM에서 소통할 연락처를\n입력해 주세요',
          description: '카카오톡 오픈채팅방, SNS 계정 등\n공개 가능한 연락처로 작성해 주세요.',
          hintText: '연락처',
          controller: _contactController,
          allowEmptyConfirm: true,
          onConfirm: _next,
          onSkip: _goHome,
        );
      case 5:
      default:
        return _TextInputStep(
          title: '마지막이에요!\n자기소개를 작성해 주세요✍️',
          description: '50자 이내로 작성해 주세요 (선택)',
          hintText: '예시)주말마다 합주하고 싶은 직장인 드러머예요 🥁',
          controller: _bioController,
          maxLines: 4,
          maxLength: 50,
          allowEmptyConfirm: true,
          // 자기소개 '확인' → 홈으로 이동 후 완료 오버레이 노출.
          onConfirm: _finishToHome,
          onSkip: _goHome,
        );
    }
  }
}

/// 스텝 하단 공통: '확인' 기본 버튼 + 선택적 '다음에 작성할게요' 텍스트 버튼.
class _StepFooter extends StatelessWidget {
  final bool enabled;
  final VoidCallback onConfirm;
  final VoidCallback? onSkip;
  final String confirmText;

  const _StepFooter({
    required this.onConfirm,
    this.onSkip,
    this.enabled = true,
    this.confirmText = '확인',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSeed.boldOrangeStrong.color,
              disabledBackgroundColor: ColorSeed.meticulousGrayLight.color,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (onSkip != null) ...[
          const SizedBox(height: 22),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '다음에 작성하기',
              style: TextStyle(
                fontSize: 14,
                color: ColorSeed.meticulousGrayMedium.color,
                decoration: TextDecoration.underline,
                decorationColor: ColorSeed.meticulousGrayMedium.color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String text;
  const _StepTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: ColorSeed.organizedBlackMedium.color,
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 원본 비율(1624x1165)로 full width 높이를 계산.
    final imageHeight = screenWidth * 1165 / 1624;
    return Column(
      children: [
        const Spacer(),
        // 본문 가로 패딩(24)을 OverflowBox로 벗어나 화면 full width로 노출.
        SizedBox(
          height: imageHeight,
          child: OverflowBox(
            minWidth: screenWidth,
            maxWidth: screenWidth,
            minHeight: imageHeight,
            maxHeight: imageHeight,
            child: Image.asset(
              'assets/images/onboarding_welcome.png',
              width: screenWidth,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 환영 스텝 전용 타이틀 (공용 _StepTitle 미사용).
        const Text(
          'JAM에 오신 걸 환영해요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '함께 합주할 밴드와 멤버를\nJAM에서 찾아보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: ColorSeed.organizedBlackLight.color,
          ),
        ),
        const Spacer(),
        _StepFooter(onConfirm: onNext, confirmText: '다음'),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SessionStep extends StatelessWidget {
  final String? name;
  final String Function(String?) honorific;
  final Set<SessionEnum> selected;
  final ValueChanged<SessionEnum> onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  const _SessionStep({
    required this.name,
    required this.honorific,
    required this.selected,
    required this.onToggle,
    required this.onConfirm,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final who = honorific(name);
    final title = who.isEmpty ? '어떤 세션이세요?' : '$who은 어떤 세션이세요?';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _StepTitle(title),
        const SizedBox(height: 12),
        Text(
          '다룰 수 있는 세션을 모두 선택해 주세요',
          style: TextStyle(
            fontSize: 14,
            color: ColorSeed.meticulousGrayMedium.color,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: SessionEnum.values.map((session) {
                return _SessionCard(
                  session: session,
                  selected: selected.contains(session),
                  onTap: () => onToggle(session),
                );
              }).toList(),
            ),
          ),
        ),
        _StepFooter(onConfirm: onConfirm, onSkip: onSkip),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// 세션 선택 카드. session_selector.dart의 카드 디자인(80x80 이미지 + 하단 라벨,
/// 선택 시 active 이미지로 토글)을 그대로 따른다.
class _SessionCard extends StatelessWidget {
  final SessionEnum session;
  final bool selected;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Image.asset(
              selected
                  ? sessionImagesActive[session]!
                  : sessionImagesDefault[session]!,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: Text(
                sessionMap[session]!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreStep extends StatelessWidget {
  final String? name;
  final String Function(String?) honorific;
  final Set<_Genre> selected;
  final ValueChanged<_Genre> onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  const _GenreStep({
    required this.name,
    required this.honorific,
    required this.selected,
    required this.onToggle,
    required this.onConfirm,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final who = honorific(name);
    final title =
        who.isEmpty ? '멋져요! 🎵\n음악 취향을 알려주세요' : '멋져요! 🎵\n$who의 음악 취향을 알려주세요';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _StepTitle(title),
        const SizedBox(height: 12),
        Text(
          '좋아하는 장르를 모두 골라 주세요',
          style: TextStyle(
            fontSize: 14,
            color: ColorSeed.meticulousGrayMedium.color,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _Genre.values.map((genre) {
                return _ChoiceChip(
                  label: _genreLabels[genre]!,
                  selected: selected.contains(genre),
                  onTap: () => onToggle(genre),
                );
              }).toList(),
            ),
          ),
        ),
        _StepFooter(onConfirm: onConfirm, onSkip: onSkip),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TextInputStep extends StatefulWidget {
  final String title;
  final String? description;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final bool allowEmptyConfirm;
  final VoidCallback onConfirm;
  final VoidCallback? onSkip;

  /// 입력 글자 수 제한. null이면 제한 없음. (기본 카운터는 숨긴다)
  final int? maxLength;

  /// 입력 하단에 노출할 에러 메시지. null이면 숨김. 값이 있으면 '확인'도 비활성화된다.
  final String? errorText;

  /// 입력값이 바뀔 때마다 호출. (닉네임 중복 검사 등 외부 검증용)
  final ValueChanged<String>? onChanged;

  const _TextInputStep({
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onConfirm,
    this.description,
    this.maxLines = 1,
    this.allowEmptyConfirm = false,
    this.onSkip,
    this.maxLength,
    this.errorText,
    this.onChanged,
  });

  @override
  State<_TextInputStep> createState() => _TextInputStepState();
}

class _TextInputStepState extends State<_TextInputStep> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _TextInputStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 닉네임·연락처·자기소개 스텝은 같은 위젯 타입이라 State가 재사용된다.
    // 컨트롤러가 바뀌면 리스너도 새 컨트롤러로 옮겨줘야 '확인' 활성화가 동작한다.
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasText =
        widget.allowEmptyConfirm || widget.controller.text.trim().isNotEmpty;
    final enabled = hasText && widget.errorText == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _StepTitle(widget.title),
        if (widget.description != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: ColorSeed.meticulousGrayMedium.color,
            ),
          ),
        ],
        const SizedBox(height: 32),
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: ColorSeed.meticulousGrayMedium.color),
            // 가로/세로 여백을 동일하게.
            contentPadding: const EdgeInsets.all(16),
            // 기본 글자 수 카운터는 숨긴다.
            counterText: '',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: ColorSeed.boldOrangeStrong.color, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: ColorSeed.meticulousGrayLight.color),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 16,
                color: ColorSeed.boldOrangeStrong.color,
              ),
              const SizedBox(width: 6),
              Text(
                widget.errorText!,
                style: TextStyle(
                  fontSize: 13,
                  color: ColorSeed.boldOrangeStrong.color,
                ),
              ),
            ],
          ),
        ],
        const Spacer(),
        _StepFooter(
          onConfirm: widget.onConfirm,
          onSkip: widget.onSkip,
          enabled: enabled,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// 홈 위에 딤드로 뜨는 '작성 완료' 오버레이. 페이드 인 후 4초 뒤 페이드 아웃하며
/// 스스로 사라진다([onDismiss]로 OverlayEntry를 제거).
class _CompletionOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _CompletionOverlay({required this.onDismiss});

  @override
  State<_CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<_CompletionOverlay> {
  static const Duration _fade = Duration(milliseconds: 250);
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // 페이드 인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: _fade,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            color: Colors.black.withOpacity(0.55),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/onboarding_complete.png',
                    width: 140,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '프로필 완성!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorSeed.boldOrangeStrong.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '이제 JAM에서 밴드와 멤버를 만나보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: ColorSeed.organizedBlackMedium.color,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorSeed.boldOrangeStrong.color,
                        side: BorderSide(
                          color: ColorSeed.boldOrangeStrong.color,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'JAM 시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ColorSeed.boldOrangeStrong.color : Colors.white,
          border: Border.all(
            color: selected
                ? ColorSeed.boldOrangeStrong.color
                : ColorSeed.meticulousGrayLight.color,
            // 선택 시 두께가 바뀌면 border가 레이아웃 크기에 포함돼 칩이 커진다.
            // 두께를 고정해 크기 변화를 막는다.
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color:
                selected ? Colors.white : ColorSeed.organizedBlackMedium.color,
          ),
        ),
      ),
    );
  }
}
