# lets_jam 프로젝트

## 개요

- **앱 이름**: lets_jam ("함께할 때 더 째미난 음악!")
- **플랫폼**: Flutter (iOS 중심)
- **Bundle ID**: com.chunkybuddy.letsjam
- **Git 브랜치**: main

## 기술 스택

- Flutter SDK >=3.4.1 <4.0.0
- 상태관리: GetX (get: ^4.7.2)
- 라우팅: go_router ^14.0.0 + app_links ^6.0.0 (딥링크)
- 백엔드: Supabase (supabase_flutter: ^2.0.0)
- 인증: 카카오 로그인 (kakao_flutter_sdk: ^1.9.3)
- 환경변수: flutter_dotenv (.env 파일)
- 폰트: Pretendard (assets/fonts/Pretendard-Regular.otf)

## 프로젝트 구조 (lib/)

```
lib/
  main.dart
  screens/
    splash_screen.dart
    welcome_screen.dart
    default_navigation.dart
    terms_agreement_screen.dart / terms_detail_screen.dart
    alarm_screen.dart
    band_screen.dart
    explore_screen/
    liked_screen/
    post_detail_screen/
    profile_screen/
    settings_screen/
    upload_screen/
  models/
    post_model.dart / reply_model.dart / profile_model.dart
    session_enum.dart / region_enum.dart / level_enum.dart / age_enum.dart
  controllers/
    explore_filter_controller.dart
    session_controller.dart
  widgets/  (공통 위젯들)
  utils/    (helper, date_parser, color_seed_enum 등)
  compositions/
    scroll_tracker.dart
```

## 에셋 경로

- assets/images/
- assets/images/session_selector/
- assets/icons/
- assets/icons/bottom_nav/
- 앱 아이콘: assets/icons/app_icon.png

## iOS 빌드 / Fastlane

- **Team ID**: J262X57F7K
- **Key ID**: BHM5SMRV9F
- **Issuer ID**: f9d63cd7-3347-44d5-9b75-7ac4ddabb1db
- **Key 파일**: ios/fastlane/AuthKey_BHM5SMRV9F.p8
- **Provisioning Profile**: "match AppStore com.chunkybuddy.letsjam"

### Fastlane 레인

- `fastlane beta` - TestFlight 빌드 & 업로드
- `fastlane release` - App Store Connect 업로드 (submit_for_review: false로 설정됨)
- 빌드 흐름: flutter build ios --release --no-codesign → increment_build_number → build_app → upload
