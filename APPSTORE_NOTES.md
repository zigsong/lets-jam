# App Store 재심사를 위한 수동 작업 목록

## Guideline 1.5 - Support URL
App Store Connect에서 Support URL을 실제 고객지원 정보가 있는 페이지로 변경해야 합니다.
- 현재: https://letsjam.work/intro
- 제안: 문의 폼 URL (https://forms.gle/6JcnqBmy8Aaim5qv6) 또는 별도 지원 페이지 생성

## Guideline 4.8 - Sign in with Apple
코드 구현 완료. 추가 필요 작업:
1. Supabase 대시보드 > Authentication > Providers > Apple 활성화
2. Apple Developer Console에서 Sign in with Apple 서비스 ID 생성
3. App Store Connect > Capabilities에서 Sign in with Apple 기능 활성화

## Guideline 1.2 - UGC 콘텐츠 조정
코드 구현 완료 (신고/차단 버튼, 커뮤니티 이용규칙 약관 추가됨). 추가 필요 작업:
1. Supabase에 `reports` 테이블 생성:
   ```sql
   create table reports (
     id uuid default gen_random_uuid() primary key,
     reporter_id uuid references auth.users(id) on delete cascade,
     reported_post_id uuid references posts(id) on delete cascade,
     reason text,
     created_at timestamptz default now()
   );
   alter table reports enable row level security;
   create policy "Users can insert their own reports" on reports for insert with check (auth.uid() = reporter_id);
   ```
2. Supabase에 `blocked_users` 테이블 생성:
   ```sql
   create table blocked_users (
     id uuid default gen_random_uuid() primary key,
     blocker_id uuid references auth.users(id) on delete cascade,
     blocked_id uuid references auth.users(id) on delete cascade,
     created_at timestamptz default now(),
     unique(blocker_id, blocked_id)
   );
   alter table blocked_users enable row level security;
   create policy "Users can manage their own blocks" on blocked_users for all using (auth.uid() = blocker_id);
   ```
3. 24시간 내 신고 처리 운영 프로세스 수립 (Supabase 대시보드 모니터링 필요)

## App Review 답변 시 스크린 레코딩 필요 항목
- Guideline 5.1.1(v): 계정 생성 → 설정 이동 → '회원 탈퇴 (계정 삭제)' 탭 → 삭제 확인
- Guideline 1.2: EULA 동의 화면 → 게시글 신고 → 사용자 차단
