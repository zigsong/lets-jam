# FCM 푸쉬 알림 구현 플랜

> 목표: 댓글 등 정보성 이벤트 발생 시, 앱이 꺼져 있어도 기기에 뜨는 **푸쉬 알림**을 제공한다.
> 방식: **FCM(Firebase Cloud Messaging) + APNs**. 발송 트리거는 Supabase.
>
> **확정된 범위 (2026-11-09)**
>
> - 알림 대상 이벤트: **댓글만** (게시글에 댓글 → 게시글 작성자)
>   - ~~대댓글~~ → **앱에 대댓글 기능 자체가 없음**(`comments` 테이블에 parent 컬럼 없음)이라 제외
>   - 좋아요/밴드는 추후
> - 지원 플랫폼: **iOS만** (Android는 추후, FCM이라 토큰만 받으면 확장 쉬움)
> - 선행 수동 작업(Phase 0) 상세 가이드: [`fcm-phase0-setup.md`](./fcm-phase0-setup.md)
>
> **확인된 DB 구조 (MCP 조회)**
> - 댓글 테이블: `comments` (id, created_at, post_id, user_id, content) — 평면 구조
> - 트리거: `comments` AFTER INSERT → `create_comment_notification()` → `notifications`에 행 생성
>   - `recipient_id` = 게시글 작성자, `actor_id` = 댓글 작성자, `type='comment'`, 본인 댓글 제외
> - `notifications.type`은 현재 `'comment'` 하나뿐

---

## 1. 현재 상태 (as-is)

- **인앱 알림만 존재.** `notifications` 테이블의 안 읽은 row를 폴링해서 벨 아이콘에 표시.
  - `NotificationController.fetchNotifications()` — 앱 resume / 로그인 변경 시 조회
  - 클라이언트는 `notifications`를 **읽기/읽음처리만** 함 → **row 생성은 DB 트리거가 서버에서 담당** (댓글 insert 시 자동 생성으로 추정)
- `firebase_core` + `firebase_analytics`만 있고 **`firebase_messaging` 없음** = 진짜 푸쉬 없음.
- `NotificationController.enabled` 는 개발자 테스트용 on/off (기본 false).

### `notifications` 테이블 (모델 기준)

| 컬럼           | 의미                            |
| -------------- | ------------------------------- |
| `id`           | PK                              |
| `created_at`   | 생성 시각                       |
| `recipient_id` | 알림 받을 유저 (= 푸쉬 대상)    |
| `actor_id`     | 알림 유발한 유저 (댓글 단 사람) |
| `type`         | 알림 종류 (예: comment)         |
| `post_id`      | 관련 게시글                     |
| `comment_id`   | 관련 댓글                       |
| `is_read`      | 읽음 여부                       |

→ **푸쉬 발송 훅 포인트: `notifications` 테이블 INSERT.** 이미 수신자/게시글 정보가 다 들어있어 그대로 활용 가능.

---

## 2. 목표 아키텍처 (to-be)

```
[댓글 작성]
    │  (기존 DB 트리거)
    ▼
[notifications INSERT] ──(Supabase DB Webhook)──▶ [Edge Function: send-push]
                                                        │
                                   recipient_id로 user_devices 조회 → FCM 토큰
                                                        │
                                                        ▼
                                                  [FCM HTTP v1 API]
                                                        │
                                              ┌─────────┴─────────┐
                                        (iOS)APNs           (Android)
                                              │
                                              ▼
                                      [기기에 푸쉬 표시]
                                              │  (탭)
                                              ▼
                                  [앱 실행 → /posts/:postId 딥링크]
```

---

## 3. 단계별 구현

### Phase 0 — APNs / Firebase 콘솔 세팅 (수동, 사용자 작업) ⚠️

> 코드가 아니라 콘솔/인증서 작업. **이게 선행돼야 나머지가 동작함.**

- [ ] Apple Developer에서 **APNs 인증키(.p8) 발급** (Keys → Apple Push Notifications service)
  - ⚠️ fastlane 업로드용 `AuthKey_BHM5SMRV9F.p8`와 **별개**. 푸쉬 전용 키를 새로 발급.
  - `.p8` 키 하나로 Sandbox/Production 모두 커버 → TestFlight·개발 둘 다 동작
- [ ] Firebase 콘솔 → 프로젝트 설정 → Cloud Messaging → **APNs 인증키 업로드** (Key ID, Team ID: `J262X57F7K` 입력)
- [ ] Xcode에서 Runner 타겟에 Capability 추가
  - **Push Notifications**
  - **Background Modes → Remote notifications**
- [ ] `ios/Runner/Info.plist` / entitlements 확인 (`aps-environment`)
- [ ] Firebase 콘솔 → 프로젝트에 **서비스 계정 키(JSON) 발급** (Edge Function에서 FCM 호출용)

### Phase 1 — 클라이언트: FCM 토큰 등록 ✅ (코드 완료)

- [x] `pubspec.yaml`에 `firebase_messaging: ^16.0.0` 추가 (16.2.0 resolved)
- [x] 앱 시작 시 알림 권한 요청 (`requestPermission`) — `PushNotificationController._setup()`
- [x] FCM 토큰 발급 (`getToken`) + 갱신 리스너 (`onTokenRefresh`)
- [x] 토큰을 Supabase `user_devices`에 저장 (로그인 시 / `ever(isLoggedIn)`)
- [x] 로그아웃 시 토큰 삭제 (`SessionController.signOut`에서 `removeToken` 선호출)
- **구현 파일:** `lib/controllers/push_notification_controller.dart`, `main.dart`, `session_controller.dart`
- **남은 수동 작업:** ① `user_devices` 테이블 SQL 실행 ② 재빌드(pod install) ③ 로그인 후 토큰 저장 확인

### Phase 2 — DB: 토큰 저장소 + 트리거 ✅ 완료

- [x] `user_devices` 테이블 + RLS 4개 (`supabase/migrations/20261109000000_create_user_devices.sql`)
- [x] 댓글→notifications 트리거 확인: `comments` AFTER INSERT → `create_comment_notification()`
- [x] `notifications` INSERT Webhook: `pg_net` + 트리거 `on_notification_send_push` → `send-push` 호출
  - secret은 Supabase Vault(`push_webhook_secret`)에서 읽음 (git에 미노출)
  - `supabase/migrations/20261109000100_add_push_webhook.sql`

### Phase 3 — Edge Function: 푸쉬 발송 ✅ 배포됨

- [x] `supabase/functions/send-push/index.ts` — 서비스계정 JWT로 FCM v1 OAuth, 토큰 조회,
      문구 구성(닉네임+댓글내용), 무효 토큰 자동 정리
- [x] Secrets: `FIREBASE_SERVICE_ACCOUNT`, `WEBHOOK_SECRET` (대시보드 설정 완료)
- [x] 배포 완료 (verify_jwt=false, webhook secret으로 자체 인증)
- **미검증:** 실제 FCM 발송은 실기기 토큰이 있어야 확인 가능 (또는 가짜 토큰 연결 테스트)

### Phase 4 — 클라이언트: 수신 & 딥링크 ✅ 완료 (`main.dart`)

- [x] 메시지 수신 처리
  - 포그라운드 `onMessage` → `NotificationController.fetchNotifications()`로 벨 갱신 (배너는 OS가 표시)
  - 백그라운드 `onMessageOpenedApp`, 종료 `getInitialMessage` (탭 진입)
  - top-level `onBackgroundMessage` 핸들러 등록
- [x] go_router에 `/posts/:postId` 라우트 추가 (userId는 쿼리 `?uid=`)
- [x] 알림 탭 → `post_id`(+`post_user_id`)로 게시글 상세 이동
  - 스플래시 중 탭은 `_pendingPushLocation`에 보관 후 라우터 준비되면 이동
- [x] Edge Function에 `post_user_id`(=작성자=수신자) 추가 → PostDetailScreen(userId) 구성

### Phase 5 — 테스트

- [ ] 로컬: Firebase 콘솔 "테스트 메시지" 로 토큰 직접 지정해 발송 확인
- [ ] 실제 플로우: 테스트 계정 2개로 댓글 → 푸쉬 수신 확인
- [ ] **TestFlight 빌드로 Production APNs 경로 검증** (Sandbox와 환경 다름 — 반드시 확인)
- [ ] 앱 종료 상태에서 푸쉬 탭 → 게시글 딥링크 이동 확인

---

## 4. 확인/결정 필요 사항

- [x] ~~알림 타입 범위~~ → **댓글 + 대댓글** 확정
- [x] ~~안드로이드 지원 여부~~ → **iOS만** 확정
- [ ] 댓글/대댓글 → `notifications` INSERT가 정말 DB 트리거인지 (아니면 다른 경로인지) SQL로 확정
  - 대댓글도 `notifications`에 row가 생기는지 함께 확인 (안 생기면 트리거 보강 필요)
- [ ] 알림 문구 카피 (한국어) — 댓글 vs 대댓글 구분 (`type`으로)
- [ ] 수신 거부/설정 화면 UX (OS 설정으로 보낼지, 앱 내 토글 둘지)

---

## 5. 비용

| 항목                   | 비용                                    |
| ---------------------- | --------------------------------------- |
| FCM (Firebase)         | 무료 · 무제한 (Spark 플랜)              |
| APNs (Apple)           | 무료 (기존 Apple Developer 멤버십 포함) |
| Supabase Edge Function | 무료 티어 충분 (월 50만 호출)           |

→ **추가 비용 없음.**

---

## 6. 작업 분담

- **사용자(수동):** Phase 0 전체 (APNs 키, Firebase 콘솔, Xcode Capability)
- **코드 구현 가능:** Phase 1~4 (Flutter 클라이언트, DB 마이그레이션, Edge Function)
