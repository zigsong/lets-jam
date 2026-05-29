# lets_jam 코드 개선 제안 문서

> 본 문서는 `lib/` 디렉토리 전체(74개 Dart 파일)에 대한 코드 리뷰 결과를 정리한 것입니다.
> 모든 제안은 **기존 기능을 그대로 유지**하면서 **가독성, 유지보수성, 일관성**을 개선하는 것을 목표로 합니다.
> 실제 코드는 수정하지 않았으며, 우선순위와 효과를 기준으로 제안만 기술합니다.

---

## 목차

1. [High Priority — 즉시 개선 권장](#1-high-priority--즉시-개선-권장)
   - 1.1 `customSnackbar` 와 `CustomSnackbar` 중복 정의 통합
   - 1.2 로그인/프로필 가드 로직 중복 제거 (`AuthGuard` 헬퍼)
   - 1.3 `throw Error;` 잘못된 패턴 수정
   - 1.4 Supabase 스토리지 경로 파싱 헬퍼화
   - 1.5 프로필 아바타 위젯 중복 (8회) → 공용 위젯화
   - 1.6 `main.dart`의 splash delay 위치 오류
2. [Medium Priority — 일관성/구조 개선](#2-medium-priority--일관성구조-개선)
   - 2.1 `PostDetailScreen` 분리 (820라인 → 컴포넌트 분리)
   - 2.2 `SessionController.deleteAccount`의 try/catch 중복
   - 2.3 인증 후 `_fetchUserById` 내부 `setState` 부작용 분리
   - 2.4 이미지 업로드 로직 중복 (`_uploadImages` 2벌)
   - 2.5 `ExploreFilterController.toggleRegion`의 중복 조건 정리
   - 2.6 `Navigator.push` + `MaterialPageRoute` 반복 → 라우팅 헬퍼
   - 2.7 폼 validation 로직 표준화
3. [Low Priority — 사소한 정리](#3-low-priority--사소한-정리)
   - 3.1 불필요한 `.toList()` 호출 제거
   - 3.2 `WidgetsFlutterBinding.ensureInitialized()` 중복 호출
   - 3.3 dead code 및 주석처리된 코드 제거
   - 3.4 magic number/색상 상수화
   - 3.5 `.then((_) => ...)` → `async/await` 일관성
4. [구조 개선 제안 (선택사항)](#4-구조-개선-제안-선택사항)

---

## 1. High Priority — 즉시 개선 권장

### ✅ 1.1 `customSnackbar` 와 `CustomSnackbar` 중복 정의 통합

**문제점**

동일한 목적의 스낵바가 두 곳에 정의되어 있고, 스타일도 미묘하게 다릅니다.

- `/Users/songjieun/Desktop/lets_jam/lib/utils/custom_snackbar.dart` — `SnackBar customSnackbar(String text)` 함수형
- `/Users/songjieun/Desktop/lets_jam/lib/widgets/custom_snackbar.dart` — `class CustomSnackbar extends SnackBar` 클래스형

두 가지가 혼재되어 같은 파일 안에서도 둘 다 import 되는 경우가 있습니다.

```dart
// post_detail_screen.dart
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_snackbar.dart';
...
scaffoldMessenger.showSnackBar(customSnackbar("게시글이 삭제되었어요"));   // 함수형
ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar(content: '신고가 접수되었어요')); // 클래스형
```

**개선 방향**

- 하나의 API로 통합 (스타일이 거의 같으므로 `customSnackbar(String)` 함수형 권장).
- `widgets/custom_snackbar.dart`는 제거하거나 deprecate 처리 후 점진적 마이그레이션.
- 사용처 약 16개 파일 모두 단일 import로 정리.

**예상 효과**

- import 혼란 제거, 디자인 일관성 확보 (현재 두 스낵바의 corner radius, padding, background opacity 다름).
- 디자인 변경 시 단일 지점에서 수정 가능.

---

### ✅ 1.2 로그인/프로필 가드 로직 중복 제거

**문제점**

"로그인 후 이용 가능" / "프로필 작성 안내" 모달이 4개 파일에서 동일한 로직으로 반복됩니다.

| 파일                      | 라인                              |
| ------------------------- | --------------------------------- |
| `default_navigation.dart` | L66-94 (`_onProfileButtonTapped`) |
| `default_navigation.dart` | L182-209 (글쓰기 버튼)            |
| `reply_input.dart`        | L92-119 (`onTap`)                 |

모두 동일한 패턴:

```dart
if (sessionController.isLoggedIn.value == false) {
  showModal(desc: '로그인 후에 이용할 수 있어요', confirmText: '로그인', onConfirm: ...);
} else if (sessionController.hasProfile.value == false) {
  showModal(desc: '프로필이 없어요.\n프로필을 작성할까요?', confirmText: '작성하기', ...);
}
```

**개선 방향**

`utils/auth_guard.dart` 신설 후 공용 함수로 추출:

```dart
/// 인증/프로필이 필요한 액션을 실행하기 전에 호출.
/// 인증/프로필이 모두 충족되면 [onAuthorized] 실행.
bool requireAuthAndProfile(
  BuildContext context, {
  required VoidCallback onAuthorized,
}) {
  final s = Get.find<SessionController>();
  if (!s.isLoggedIn.value) {
    showModal(
      context: context,
      desc: '로그인 후에 이용할 수 있어요',
      confirmText: '로그인',
      onConfirm: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      ),
      cancelText: '다음에 할게요',
    );
    return false;
  }
  if (!s.hasProfile.value) {
    showModal(
      context: context,
      desc: '프로필이 없어요.\n프로필을 작성할까요?',
      confirmText: '작성하기',
      onConfirm: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileUploadScreen()),
      ),
      cancelText: '다음에 할게요',
    );
    return false;
  }
  onAuthorized();
  return true;
}
```

사용처:

```dart
onTap: () => requireAuthAndProfile(context, onAuthorized: () {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ...));
});
```

**예상 효과**

- ~60줄 중복 코드 제거.
- 안내 문구/플로우 변경 시 단일 지점에서 수정.
- 신규 기능 추가 시 인증 가드 적용이 쉬워짐.

---

### ✅ 1.3 `throw Error;` 잘못된 패턴 수정

**문제점**

`post_detail_screen.dart` (L95, L112, L129), `reply_content.dart` (L60, L77, L91), `profile_screen.dart` (L135) 등 총 7곳에서 다음 패턴 사용:

```dart
} catch (error) {
  debugPrint('포스팅 가져오기 에러 : $error');
  throw Error;   // ← 클래스 자체를 throw (인스턴스 아님)
}
```

이는 `Error` **클래스 자체**를 throw하는 것으로 의미 없는 stack trace가 생성되고, 원래 catch한 `error` 정보가 소실됩니다.

**개선 방향**

- 의도가 "원래 에러를 다시 throw"라면 `rethrow;` 사용.
- 의도가 "특정 에러를 변환해서 던지기"라면 `throw Exception('...')` 또는 커스텀 예외.

```dart
} catch (error, stackTrace) {
  debugPrint('포스팅 가져오기 에러 : $error');
  rethrow;   // ← 원래 에러와 stack trace 유지
}
```

**예상 효과**

- 디버깅 시 정확한 에러 위치 식별 가능.
- Crash reporting (Sentry 등) 도입 시 의미 있는 로그 확보.

---

### ✅ 1.4 Supabase 스토리지 경로 파싱 헬퍼화

**문제점**

`session_controller.dart`의 `deleteAccount` (L171-218) 내에서 동일 패턴이 3번 반복됩니다:

```dart
final uri = Uri.parse(currentUser.profileImage!);
final pathSegments = uri.pathSegments;
final storageIdx = pathSegments.indexOf('images');
if (storageIdx != -1 && storageIdx + 1 < pathSegments.length) {
  imagePaths.add(pathSegments.sublist(storageIdx + 1).join('/'));
}
```

**개선 방향**

`utils/image_utils.dart`에 헬퍼 추가:

```dart
/// Supabase Storage URL에서 bucket 이후 경로만 추출.
/// 예: https://.../storage/v1/object/public/images/post/abc.jpg → post/abc.jpg
String? extractStoragePath(String url, {String bucket = 'images'}) {
  final segments = Uri.parse(url).pathSegments;
  final idx = segments.indexOf(bucket);
  if (idx == -1 || idx + 1 >= segments.length) return null;
  return segments.sublist(idx + 1).join('/');
}
```

사용:

```dart
final imagePaths = <String>[];
if (currentUser.profileImage != null) {
  final path = extractStoragePath(currentUser.profileImage!);
  if (path != null) imagePaths.add(path);
}
for (final imageUrl in currentUser.backgroundImages ?? []) {
  final path = extractStoragePath(imageUrl);
  if (path != null) imagePaths.add(path);
}
```

**예상 효과**

- 약 24줄 → 8줄로 단축.
- 향후 Supabase URL 구조 변경 시 단일 지점만 수정.

---

### ✅ 1.5 프로필 아바타 위젯 중복 → 공용 위젯화

**문제점**

거의 동일한 원형 아바타 렌더링이 8회 이상 반복됩니다 (사이즈만 다름):

```dart
Container(
  width: 40, height: 40,
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
  clipBehavior: Clip.antiAlias,
  child: user.profileImage?.isNotEmpty == true
      ? CachedNetworkImage(
          fadeInDuration: Duration.zero,
          imageUrl: supabaseImageUrl(user.profileImage!, width: 80, quality: 80),
          fit: BoxFit.cover,
          memCacheWidth: 80,
        )
      : Image.asset('assets/images/profile_avatar.png'),
);
```

발견 위치:

- `post_detail_screen.dart` L734
- `reply_input.dart` L70
- `reply_content.dart` L121
- `profile_screen.dart` L159
- `profile_upload_screen.dart` L348

**개선 방향**

`widgets/profile_avatar.dart` 신설:

```dart
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (size * 2).round();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.isNotEmpty == true
          ? CachedNetworkImage(
              fadeInDuration: Duration.zero,
              imageUrl: supabaseImageUrl(imageUrl!, width: cacheWidth, quality: 80),
              fit: BoxFit.cover,
              memCacheWidth: cacheWidth,
            )
          : Image.asset('assets/images/profile_avatar.png'),
    );
  }
}
```

**예상 효과**

- 약 90+ 줄 제거.
- placeholder 이미지 교체 시 단일 지점에서 수정.
- `memCacheWidth` 일관성 자동 보장.

---

### ✅ 1.6 `main.dart`의 splash delay 위치 오류

**문제점**

```dart
Future<void> main() async {
  /** splash screen 시간 */
  await Future.delayed(const Duration(milliseconds: 1000));   // ← (1)

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  KakaoSdk.init(...);
  await Supabase.initialize(...);

  Get.put(SessionController());

  WidgetsFlutterBinding.ensureInitialized();    // ← (2) 중복

  runApp(...);
}
```

문제:

- (1) splash delay가 **초기화 이전**에 위치 → 사용자가 검은 화면을 1초 봄.
- (2) `WidgetsFlutterBinding.ensureInitialized()`가 두 번 호출됨 (멱등이지만 의도 불명확).
- 일반적으로 `ensureInitialized()`는 가장 먼저 호출해야 함.

**개선 방향**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  KakaoSdk.init(
    nativeAppKey: dotenv.get("KAKAO_NATIVE_APP_KEY"),
    javaScriptAppKey: dotenv.get("KAKAO_JAVASCRIPT_APP_KEY"),
  );
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );
  Get.put(SessionController());

  runApp(const GetMaterialApp(home: MyApp()));
}
```

splash 화면이 필요하다면 별도 `SplashScreen` 위젯으로 표시 (이미 `splash_screen.dart`가 존재함).

**예상 효과**

- 콜드 스타트 사용자 경험 개선 (1초 빠른 진입).
- 초기화 순서 명확화.

---

## 2. Medium Priority — 일관성/구조 개선

### 2.1 `PostDetailScreen` 분리 (820라인)

**문제점**

`post_detail_screen.dart`는 820라인이며, 다음을 한 파일에 포함:

- `_PostDetailScreenState` (메인)
- `_showReportDialog` (130줄짜리 modal builder)
- `WantedSession`, `PostDetailInfo`, `PostDetailAuthorInfo` 세 위젯

**개선 방향**

디렉토리 구조 제안:

```
post_detail_screen/
  post_detail_screen.dart          (메인, ~250줄)
  widgets/
    wanted_session.dart
    post_detail_info.dart
    post_detail_author_info.dart
    post_detail_header.dart        ← 상단 그라데이션/뒤로가기/수정삭제
    report_dialog.dart             ← _showReportDialog 추출
```

특히 `_showReportDialog` (L148-278)는 자체적으로 130줄에 달하므로 분리 효과가 큽니다.

**예상 효과**

- 단일 파일 가독성 대폭 향상.
- 위젯 단위 수정 시 git diff 최소화.

---

### 2.2 `SessionController.deleteAccount`의 try/catch 중복

**문제점**

L171-227의 `deleteAccount` 내에서 동일한 URL 파싱 패턴이 3번 반복되며 try 블록 내 중복이 큽니다 (1.4와 연계).

**개선 방향**

1.4의 `extractStoragePath` 헬퍼 도입 후 다음과 같이 단순화:

```dart
Future<void> deleteAccount() async {
  final currentUser = user.value;

  if (currentUser != null) {
    try {
      final imagePaths = <String>{
        if (currentUser.profileImage != null)
          extractStoragePath(currentUser.profileImage!),
        ...?currentUser.backgroundImages?.map(extractStoragePath),
        ...(await _fetchPostImagePaths(currentUser.id)),
      }.whereType<String>().toList();

      if (imagePaths.isNotEmpty) {
        await supabase.storage.from('images').remove(imagePaths);
      }
    } catch (e) {
      debugPrint("스토리지 삭제 에러 (무시하고 계속): $e");
    }
  }

  await supabase.rpc('delete_user');

  user.value = null;
  isLoggedIn.value = false;
  hasProfile.value = false;
}

Future<List<String>> _fetchPostImagePaths(String userId) async {
  final posts = await supabase.from('posts').select('images').eq('user_id', userId);
  return posts
      .expand<dynamic>((p) => (p['images'] as List?) ?? const [])
      .map((url) => extractStoragePath(url as String))
      .whereType<String>()
      .toList();
}
```

**예상 효과**

- 약 50줄 → 25줄.
- 중복 제거 + 가독성 향상.

---

### 2.3 인증 후 `_fetchUserById` 내부 `setState` 부작용 분리

**문제점**

`post_detail_screen.dart` `_fetchUserById`와 `reply_content.dart` `_fetchUserById`가 **Future를 리턴하면서 동시에 `setState`를 호출**하는 두 가지 책임을 가집니다:

```dart
Future<ProfileModel> _fetchUserById() async {
  ...
  setState(() {
    isMyPost = author.id == sessionController.user.value?.id;
  });
  return author;
}
```

이는 `FutureBuilder` 내부에서 다시 호출될 경우 race condition을 유발할 수 있고 디버깅이 어렵습니다.

**개선 방향**

`isMyPost` 같은 파생 상태는 **getter**로 표현:

```dart
bool get isMyPost {
  final author = _cachedAuthor;
  final me = sessionController.user.value;
  return author != null && me != null && author.id == me.id;
}
```

또는 `FutureBuilder`의 `snapshot.data`로부터 직접 계산:

```dart
final isMyPost = snapshot.data?.id == sessionController.user.value?.id;
```

**예상 효과**

- 부작용 제거, 상태 일관성 보장.
- `setState` 호출 감소로 불필요한 rebuild 방지.

---

### 2.4 이미지 업로드 로직 중복 (`_uploadImages` 2벌)

**문제점**

`post_form_screen.dart` L198-218과 `profile_upload_screen.dart` L271-295에 거의 동일한 `_uploadImages` 메서드가 존재. 차이점은 prefix (`post_uploads/` vs `profile_uploads/`)뿐.

**개선 방향**

`utils/image_upload.dart` 신설:

```dart
Future<List<String>> uploadImages(
  List<String> paths, {
  required String pathPrefix,
  String bucket = 'images',
}) async {
  final supabase = Supabase.instance.client;
  final urls = <String>[];

  for (final image in paths) {
    if (image.startsWith('http')) {
      urls.add(image);
      continue;
    }
    if (FileSystemEntity.typeSync(image) != FileSystemEntityType.file) {
      continue;
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}-${image.split('/').last}';
    final res = await supabase.storage.from(bucket).upload(
      '$pathPrefix/$fileName',
      File(image),
    );
    urls.add(supabase.storage.from(bucket).getPublicUrl(res.replaceFirst('$bucket/', '')));
  }
  return urls;
}
```

**예상 효과**

- 약 40줄 중복 제거.
- 업로드 정책 변경 (예: 압축, 워터마크) 시 단일 지점에서 수정.

---

### 2.5 `ExploreFilterController.toggleRegion` 중복 조건 정리

**문제점**

```dart
void toggleRegion(District district) {
  if (tempRegions.contains(district)) {
    tempRegions.remove(district);
  } else {
    tempRegions.add(district);
  }

  // "전체" 옵션 선택 시 같은 Province의 개별 지역들 제거
  if (district.isAll && tempRegions.contains(district)) {  // ← contains 재확인
    ...
  }
  // 개별 지역 선택 시 같은 Province의 "전체" 옵션 제거
  if (!district.isAll && tempRegions.contains(district)) { // ← contains 재확인
    ...
  }
}
```

토글 직후에 `contains`를 다시 검사하는 것은 "방금 추가했다면"이라는 의도 표현으로는 부정확합니다.

**개선 방향**

```dart
void toggleRegion(District district) {
  final isAdding = !tempRegions.contains(district);
  if (isAdding) {
    tempRegions.add(district);
    if (district.isAll) {
      // 같은 Province의 개별 항목 제거
      final siblings = District.getByProvince(district.province).where((d) => !d.isAll);
      tempRegions.removeWhere(siblings.contains);
    } else {
      // 같은 Province의 "전체" 옵션 제거
      final allOption = District.getByProvince(district.province).firstWhere((d) => d.isAll);
      tempRegions.remove(allOption);
    }
  } else {
    tempRegions.remove(district);
  }
}
```

**예상 효과**

- 분기 의도 명확화.
- 미세 버그 가능성 제거 (제거 후 contains 체크하는 잘못된 흐름 방지).

---

### 2.6 `Navigator.push` + `MaterialPageRoute` 반복

**문제점**

44회 반복되는 패턴:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const SomeScreen()),
);
```

`explore_posts.dart` L150-164에서는 `Platform.isIOS`로 `CupertinoPageRoute` / `MaterialPageRoute` 분기까지 추가됩니다 (이는 한 곳에서만 적용되어 일관성 부족).

**개선 방향**

`utils/navigation.dart` 헬퍼:

```dart
Future<T?> pushScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).push<T>(
    Platform.isIOS
        ? CupertinoPageRoute(builder: (_) => screen)
        : MaterialPageRoute(builder: (_) => screen),
  );
}
```

**예상 효과**

- 플랫폼별 트랜지션 일관성 자동 적용.
- 보일러플레이트 감소.

---

### 2.7 폼 validation 로직 표준화

**문제점**

`post_form_screen.dart`와 `profile_upload_screen.dart`의 `_submit` 메서드가 매우 유사한 패턴을 가지지만 각각 직접 구현:

- 여러 에러 상태를 nullable String/bool로 개별 관리
- 에러 검사 → focus 이동 → snackbar 출력

**개선 방향**

Flutter 표준 `FormField` / `validator` 패턴 활용 또는 간단한 `FormState`-like 추상화:

```dart
class FieldError {
  final String? text;
  final FocusNode? focusOnError;
  final GlobalKey? scrollToOnError;
}
```

혹은 최소한 두 화면에서 공통되는 "에러 발생 → focus 이동 → 첫 번째 에러로 스크롤" 로직만이라도 추출.

**예상 효과**

- 폼 추가 시 일관된 UX.
- 유지보수성 향상.

---

## 3. Low Priority — 사소한 정리

### 3.1 불필요한 `.toList()` 호출 제거

`post_detail_screen.dart` L559-562:

```dart
...post.sessions
    .map((session) => sessionMap[session]!)
    .toList()       // ← 불필요
    .map((tag) => Padding(...))
```

`.map(...).map(...)`은 lazy하게 chain 가능하므로 중간 `.toList()` 제거 가능.

---

### 3.2 `WidgetsFlutterBinding.ensureInitialized()` 중복 호출

`main.dart` L42, L61 두 번 호출. 멱등이지만 의도 불명확. (1.6 참조)

---

### 3.3 Dead code 및 주석 처리된 코드 제거

- `session_controller.dart` L85-87, L163-165: `TODO: 로컬 저장` 주석 코드.
- `profile_upload_screen.dart` L37: `// final ProfileModel? _profile;` 주석 처리된 필드.
- `explore_screen.dart` L186: `// labelPadding: EdgeInsets.zero` 주석.
- `explore_posts.dart` L69: `_filterPosts`의 반환 타입 누락 (`List<PostModel>`로 명시 권장).

전반적으로 미완성 표시는 GitHub Issue 또는 별도 TODO 트래커로 옮기고 코드에서는 제거 권장.

---

### 3.4 Magic number / 색상 상수화

- `auth_screen.dart` L53: `Color(0xFFFEE500)` (카카오 노랑) → `KakaoColors.brand` 같은 상수.
- `post_detail_screen.dart` L592: `Color(0xfff5f5f5)` → `ColorSeed.organizedBlackLight` 등 기존 enum 활용.
- `post_detail_screen.dart` L312: `const threshold = 150.0;` → 클래스 상수.
- `explore_posts.dart` L136: `Color(0xFFFF6B2C)` → `ColorSeed.boldOrangeStrong.color` 사용.

전반적으로 `ColorSeed` enum이 이미 잘 정의되어 있는데, 일부 곳에서는 직접 hex를 사용해 일관성이 깨집니다.

---

### 3.5 `.then((_) => ...)` → `async/await` 일관성

`profile_screen.dart` L498:

```dart
Navigator.push(context, MaterialPageRoute(...)).then((_) => _loadPosts());
```

이미 같은 파일에서 `await` 패턴을 사용하므로 (`_loadTargetUser().then(...)`) 일관성을 위해 `await`로 통일 권장.

```dart
onTap: () async {
  await Navigator.push(context, MaterialPageRoute(...));
  if (mounted) _loadPosts();
}
```

---

## 4. 구조 개선 제안 (선택사항)

### 4.1 상태관리 일관성

현재 두 가지가 혼재:

- **GetX** (`SessionController`, `ExploreFilterController`)
- **StatefulWidget + setState** (대부분의 화면)

특히 `SessionController.user`는 GetX `Rx`이지만 `Obx`로 구독하는 곳은 일부이고, `sessionController.user.value`를 직접 읽는 곳이 더 많습니다. 이는 변경 시 화면 갱신이 누락될 위험이 있습니다.

**제안**: 인증 의존 화면은 `Obx`로 감싸거나, 명시적인 `GetBuilder` 사용.

---

### 4.2 라우팅 구조

`main.dart`에 `go_router`가 설정되어 있지만 실제로는 `/` 와 `/profiles/:profileId` 두 라우트만 등록되어 있고, 나머지는 `Navigator.push`로 처리됩니다.

**제안**: 점진적으로 모든 화면을 `go_router`로 통합 → 딥링크 지원 확장 용이.

---

### 4.3 데이터 fetching 추상화

거의 모든 화면에서 직접 `supabase.from('...').select()...` 호출. **Repository 패턴** 도입 시:

- 단위 테스트 용이.
- API 변경 영향 최소화.
- 캐싱/refresh 정책 통일.

예:

```dart
class PostRepository {
  Future<List<PostModel>> fetchAll({List<String> excludeUserIds = const []});
  Future<PostModel> fetchById(String id);
  Future<void> delete(String id);
}
```

---

### 4.4 Lint 강화

`analysis_options.yaml` 확인 후 다음 추가 권장:

- `prefer_const_constructors`
- `prefer_const_literals_to_create_immutables`
- `avoid_print` (이미 `debugPrint`로 대체 중이므로 강제)
- `unawaited_futures`
- `use_key_in_widget_constructors`

---

## 우선순위별 효과 요약

| 우선순위      | 항목 수 | 예상 코드 감소 | 주요 효과                    |
| ------------- | ------- | -------------- | ---------------------------- |
| **High**      | 6       | ~200 라인      | 버그 수정, 중복 제거, 일관성 |
| **Medium**    | 7       | ~150 라인      | 구조/유지보수성              |
| **Low**       | 5       | ~50 라인       | 코드 청결도                  |
| **구조 개선** | 4       | (장기 과제)    | 확장성, 테스트 용이성        |

**합계 예상**: 약 **400라인** 감소 + 구조적 견고성 향상.

---

## 권장 작업 순서

1. **1.3 `throw Error;` 수정** (5분, 위험도 낮음)
2. **1.6 main.dart 정리** (10분)
3. **1.1 스낵바 통합** (30분, mechanical refactor)
4. **1.5 ProfileAvatar 위젯화** (1시간)
5. **1.4 + 2.2 스토리지 헬퍼 + deleteAccount 정리** (1시간)
6. **1.2 AuthGuard 헬퍼** (1시간)
7. **2.4 이미지 업로드 헬퍼** (30분)
8. **나머지 Medium / Low 항목** (점진적)

각 단계 후 빌드 및 주요 플로우(로그인 → 글쓰기 → 댓글 → 삭제) 회귀 테스트 권장.
