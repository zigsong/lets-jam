import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lets_jam/main.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// [개발자 전용/목업] 앱 온보딩 플로우 프로토타입.
///
/// 순수 UI 목업이라 어떤 값도 Supabase에 저장하지 않는다.
/// 설정 > JAM 개발자 테스트 > '앱 온보딩'에서 진입한다.
///
/// - '다음에 작성할게요'를 누르면 어느 스텝에서든 온보딩을 종료하고 홈('/')으로 간다.
/// - 이전 스텝으로 돌아갈 수 있고, 1번에서 더 뒤로 가면 온보딩을 종료한다.
/// - 마지막(자기소개) 스텝에서 '확인'하면 홈으로 이동하고, 홈 위에
///   '작성 완료' 딤드 오버레이를 4초간 띄웠다가 자동으로 사라진다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// 온보딩에서만 쓰는 밴드 취향(장르). 아직 프로필 모델/DB에는 없는 목업 개념이다.
enum _Genre { rock, jazz, indie, kpop, jpop }

const Map<_Genre, String> _genreLabels = {
  _Genre.rock: '락',
  _Genre.jazz: '재즈',
  _Genre.indie: '인디',
  _Genre.kpop: 'K-POP',
  _Genre.jpop: 'J-POP',
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
    _nicknameController.dispose();
    _contactController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step >= _totalSteps - 1) return;
    setState(() => _step++);
  }

  void _back() {
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
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// 마지막 스텝(자기소개) '확인' → 완료 오버레이를 4초간 띄우고,
  /// 사라지면서 온보딩 등 쌓인 화면을 모두 닫고 홈 탭으로 이동한다.
  void _finishToHome() {
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
                  preferredSize: const Size.fromHeight(4),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _totalSteps,
                    minHeight: 4,
                    backgroundColor: ColorSeed.boldOrangeLight.color,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorSeed.boldOrangeStrong.color,
                    ),
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
        final who = _honorific(_name);
        final subject = who.isEmpty ? 'JAM!에서' : '$who이 JAM!에서';
        return _TextInputStep(
          title: '취향을 저장했어요.\n$subject 사용하고 싶은\n닉네임을 입력해주세요',
          hintText: '닉네임',
          controller: _nicknameController,
          onConfirm: _next,
          onSkip: _goHome,
        );
      case 4:
        final nickname = _nicknameController.text.trim();
        final greeting =
            nickname.isEmpty ? '이제 거의 다 왔어요.' : '$nickname님, 이제 거의 다 왔어요.';
        return _TextInputStep(
          title: '$greeting\nJAM에서 소통할 연락처를 입력해주세요',
          description: '카카오톡 오픈채팅방, SNS 계정 등\n공개 가능한 연락처로 작성해 주세요',
          hintText: '연락처',
          controller: _contactController,
          onConfirm: _next,
          onSkip: _goHome,
        );
      case 5:
      default:
        return _TextInputStep(
          title: '마지막으로 남기고 싶은\n자기소개가 있나요?',
          hintText: '자기소개 (선택)',
          controller: _bioController,
          maxLines: 4,
          allowEmptyConfirm: true,
          // 자기소개 '확인' → 홈으로 이동 후 완료 오버레이 노출.
          onConfirm: _finishToHome,
          // 자기소개 스텝에는 '다음에 작성할게요'가 없다.
          onSkip: null,
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
          child: ElevatedButton(
            onPressed: enabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSeed.boldOrangeStrong.color,
              disabledBackgroundColor: ColorSeed.meticulousGrayLight.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
        if (onSkip != null)
          TextButton(
            onPressed: onSkip,
            child: Text(
              '다음에 작성할게요',
              style: TextStyle(
                fontSize: 14,
                color: ColorSeed.meticulousGrayMedium.color,
              ),
            ),
          ),
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
    return Column(
      children: [
        const Spacer(),
        const _StepTitle('JAM에 오신 걸 환영해요!'),
        const SizedBox(height: 16),
        Text(
          'JAM에서 함께 음악을 할\n밴드와 멤버를 구해보세요',
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
    final title =
        who.isEmpty ? '밴드에서 어떤 세션을\n맡고 계신가요?' : '$who은 밴드에서 어떤 세션을\n맡고 계신가요?';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _StepTitle(title),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: SessionEnum.values.map((session) {
                return _ChoiceChip(
                  label: sessionMap[session] ?? session.name,
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
        who.isEmpty ? '멋져요! 밴드 취향을\n알려주세요' : '멋져요! $who의 밴드 취향을\n알려주세요';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _StepTitle(title),
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

  const _TextInputStep({
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onConfirm,
    this.description,
    this.maxLines = 1,
    this.allowEmptyConfirm = false,
    this.onSkip,
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

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final enabled =
        widget.allowEmptyConfirm || widget.controller.text.trim().isNotEmpty;
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
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: ColorSeed.meticulousGrayMedium.color),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: ColorSeed.boldOrangeStrong.color, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: ColorSeed.meticulousGrayLight.color),
            ),
          ),
        ),
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
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // 페이드 인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
    // 4초간 노출 후 페이드 아웃 → 제거
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _opacity = 0);
      Timer(_fade, widget.onDismiss);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 56,
                      color: ColorSeed.boldOrangeStrong.color,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '프로필 작성을 완료했어요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ColorSeed.organizedBlackMedium.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'JAM에서 즐거운 시간 보내세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorSeed.organizedBlackLight.color,
                      ),
                    ),
                  ],
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? ColorSeed.boldOrangeLight.color : Colors.white,
          border: Border.all(
            color: selected
                ? ColorSeed.boldOrangeStrong.color
                : ColorSeed.meticulousGrayLight.color,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? ColorSeed.boldOrangeStrong.color
                : ColorSeed.organizedBlackLight.color,
          ),
        ),
      ),
    );
  }
}
