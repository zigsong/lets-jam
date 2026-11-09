# Phase 0 — APNs / Firebase 콘솔 세팅 가이드 (수동)

> 이 문서는 **코드로 할 수 없는 콘솔/인증서 작업**을 손으로 따라 할 수 있게 정리한 것이다.
> 이 단계가 끝나야 Phase 1~4 코드가 실제로 푸쉬를 쏠 수 있다.
> 전체 플랜: [`fcm-push-plan.md`](./fcm-push-plan.md)

## 미리 준비된 값

| 항목                 | 값                                                                                |
| -------------------- | --------------------------------------------------------------------------------- |
| Team ID              | `J262X57F7K`                                                                      |
| Bundle ID            | `com.chunkybuddy.letsjam`                                                         |
| iOS 앱 Firebase 등록 | ✅ 이미 됨 (`ios/Runner/GoogleService-Info.plist` 존재)                           |
| 현재 entitlements    | `associated-domains`, `applesignin` 있음 · **`aps-environment` 없음 → 추가 필요** |

---

## Step 1. APNs 인증키(.p8) 발급 — Apple Developer

> ⚠️ fastlane 업로드용 `AuthKey_BHM5SMRV9F.p8`와 **다른 키**다. 푸쉬 전용을 새로 만든다.
> (APNs 키는 팀당 최대 2개. 이미 푸쉬용 APNs 키가 있으면 그걸 재사용해도 됨.)

1. https://developer.apple.com/account → **Certificates, IDs & Profiles**
2. 왼쪽 **Keys** → **+** 버튼
3. 이름 입력 (예: `letsjam APNs Key`)
4. **Apple Push Notifications service (APNs)** 체크 → Continue → Register
5. **Download** → `AuthKey_XXXXXXXXXX.p8` 저장
   - ⚠️ **딱 한 번만 다운로드 가능.** 안전한 곳에 보관.
6. 메모해둘 값 2개:
   - **Key ID** (파일명 `AuthKey_` 뒤 10자리)
   - **Team ID** = `J262X57F7K`

---

## Step 2. Firebase 콘솔에 APNs 키 등록

1. https://console.firebase.google.com → 해당 프로젝트
2. ⚙️ **프로젝트 설정** → **Cloud Messaging** 탭
3. **Apple 앱 구성** 섹션 → `com.chunkybuddy.letsjam` 항목
4. **APNs 인증 키** → **업로드**
5. Step 1의 `.p8` 파일 업로드 + **Key ID**, **Team ID**(`J262X57F7K`) 입력 → 업로드
6. ✅ 등록되면 Sandbox/Production **둘 다 자동 커버** (TestFlight·개발 모두 동작)

---

## Step 3. Firebase 서비스 계정 키 발급 (Edge Function용)

> Phase 3의 Edge Function이 FCM API를 호출할 때 인증에 쓴다.

1. Firebase 콘솔 → ⚙️ **프로젝트 설정** → **서비스 계정** 탭
2. **새 비공개 키 생성** → JSON 다운로드
3. ⚠️ 이 JSON은 **민감 정보**. git에 올리지 말 것. Phase 3에서 Supabase Secrets로만 주입.

---

## Step 4. Xcode에서 Push 역량(Capability) 추가

1. Xcode로 `ios/Runner.xcworkspace` 열기
2. 왼쪽 **Runner** 타겟 선택 → **Signing & Capabilities** 탭
3. **+ Capability** 클릭 → **Push Notifications** 추가
   - → `Runner.entitlements`에 `aps-environment` 가 자동 추가됨
4. 다시 **+ Capability** → **Background Modes** 추가
   - 체크: **Remote notifications**
   - → `Info.plist`에 `UIBackgroundModes > remote-notification` 추가됨
5. 저장 후, `Runner.entitlements`에 아래가 생겼는지 확인:
   ```xml
   <key>aps-environment</key>
   <string>development</string>
   ```
   (배포 빌드에서는 Xcode/프로비저닝이 자동으로 `production`으로 처리)

> ℹ️ 프로비저닝 프로파일(`match AppStore com.chunkybuddy.letsjam`)에 Push 권한이 포함돼야 한다.
> match를 쓰므로, 필요 시 프로파일 재생성(`fastlane match development` / `appstore`)이 필요할 수 있음.

---

## Step 5. 세팅 검증 (코드 없이)

1. Phase 1 코드로 기기에서 FCM 토큰을 하나 확보한 뒤,
2. Firebase 콘솔 → **Messaging** → **테스트 메시지 전송** → 토큰 직접 입력 → 발송
3. 기기에 푸쉬가 뜨면 Phase 0 성공.

---

## 완료 체크리스트

- [ ] APNs 인증키(.p8) 발급 + Key ID 메모
- [ ] Firebase Cloud Messaging에 APNs 키 업로드
- [ ] Firebase 서비스 계정 JSON 발급 (보관만, 아직 사용 X)
- [ ] Xcode: Push Notifications capability 추가
- [ ] Xcode: Background Modes → Remote notifications 체크
- [ ] `Runner.entitlements`에 `aps-environment` 확인
- [ ] (Phase 1 후) Firebase 테스트 메시지로 실제 수신 확인

→ 여기까지 끝나면 **Phase 1(firebase_messaging + 토큰 저장)** 코드 작업 시작.
