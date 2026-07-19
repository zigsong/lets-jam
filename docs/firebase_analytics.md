# Firebase Analytics 연동 가이드

lets_jam 앱의 Firebase Analytics(FlutterFire) 연동 현황과 운영 메모.

- **Firebase 프로젝트**: `jamlog-b8e50` (프로젝트 번호 `337968552397`)
- **iOS 앱(데이터 스트림)**: `lets_jam` / Bundle ID `com.chunkybuddy.letsjam`
- **연동 방식**: FlutterFire (`firebase_core` + `firebase_analytics`)

## 현재 구성

| 항목          | 위치 / 값                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------- |
| 패키지        | `pubspec.yaml` — `firebase_core`, `firebase_analytics`                                      |
| 초기화        | `lib/main.dart` — `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` |
| 플랫폼 설정   | `lib/firebase_options.dart` (flutterfire 생성, 직접 수정 금지)                              |
| iOS 설정 파일 | `ios/Runner/GoogleService-Info.plist` (Xcode Runner 타겟에 등록됨)                          |
| Pod 관리      | `firebase_core` 플러그인이 자동 처리 — Podfile에 수동 `pod` 추가 불필요                     |
| AppDelegate   | **수정하지 않음** — Firebase 콘솔이 주는 네이티브 초기화 코드는 Flutter 앱에 붙이면 안 됨   |

> 재설정이 필요하면 `flutterfire configure --project=jamlog-b8e50 --ios-bundle-id=com.chunkybuddy.letsjam` 실행.

## 자동으로 수집되는 것

앱이 Firebase 초기화된 채 실행되면 **추가 설정 없이** 다음이 자동 수집된다.

- 앱 최초 실행 (`first_open`)
- 세션 시작 (`session_start`)
- 앱 업데이트, OS 업데이트
- 인앱 기본 이벤트 / 사용자 기기·지역 등 기본 속성

→ 대시보드에서 의무적으로 더 설정할 항목은 없다.

## 알아둘 점

| 항목                     | 내용                                                                                              |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| **데이터 반영 시간**     | 표준 리포트는 최대 24시간 지연. 즉시 확인은 **DebugView** 또는 실시간(Realtime) 리포트 사용       |
| **DebugView 테스트**     | Xcode 실행 인자에 `-FIRDebugEnabled` 추가 시 이벤트가 실시간으로 DebugView에 표시됨 (개발 검증용) |
| **커스텀 이벤트**        | "버튼 클릭", "글 작성" 같은 건 자동 수집 안 됨 → Dart 코드에서 직접 `logEvent` 호출 필요          |
| **화면 추적(go_router)** | 자동 화면 추적이 go_router와 깔끔하게 안 맞을 수 있음 → `FirebaseAnalyticsObserver` 연결 권장     |

## DebugView로 연동 검증 (개발 중)

1. Xcode → Runner Scheme → Edit Scheme → Run → Arguments → "Arguments Passed On Launch"에 `-FIRDebugEnabled` 추가
2. 앱 실행
3. Firebase 콘솔 → Analytics → **DebugView**에서 이벤트가 실시간으로 들어오는지 확인

## 커스텀 이벤트 로깅 (예시)

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// 글 작성 완료
await analytics.logEvent(
  name: 'create_post',
  parameters: {
    'post_type': postType.name, // findBand / findMember
  },
);
```

> 이벤트 이름은 영문 소문자/숫자/언더스코어, 40자 이내. 예약어(`firebase_`, `google_`, `ga_` 접두사)는 사용 금지.

## go_router 화면 추적 (옵션)

`FirebaseAnalyticsObserver`를 `GoRouter`의 `observers`에 추가하면 라우트 전환이 `screen_view`로 기록된다.

```dart
final appRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [
    routeObserver,
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  // ...
);
```

> 정확한 화면 이름을 남기려면 각 `GoRoute`에 `name`을 지정하는 것을 권장.

## 권장 다음 단계

1. `flutter run`으로 앱 부팅 확인 (Firebase 크래시 없는지)
2. `-FIRDebugEnabled` + DebugView로 이벤트 수신 검증
3. 분석이 필요한 사용자 행동(글 작성/좋아요/신고 등)에 커스텀 이벤트 추가
4. 필요 시 go_router Observer 연결로 화면 흐름 추적
