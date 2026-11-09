-- FCM 푸쉬 토큰 저장 테이블
-- 한 유저가 여러 기기를 쓸 수 있으므로 (user_id, fcm_token)를 1행으로 저장한다.
create table if not exists public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  fcm_token text not null unique,
  platform text not null default 'ios',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_devices_user_id_idx
  on public.user_devices (user_id);

-- RLS: 본인 토큰만 다룰 수 있게 (기존 테이블 RLS 컨벤션과 동일)
alter table public.user_devices enable row level security;

-- 조회: 본인 기기만
create policy "user_devices_select_own"
  on public.user_devices
  for select
  using (auth.uid() = user_id);

-- 등록: 본인 user_id로만
create policy "user_devices_insert_own"
  on public.user_devices
  for insert
  with check (auth.uid() = user_id);

-- 수정/인수: 기기를 소유한 사람이 토큰 행을 자기 것으로 갱신 가능
-- (같은 기기에서 다른 계정으로 로그인하면 토큰 주인이 바뀌어야 하므로 using은 true)
create policy "user_devices_update_own"
  on public.user_devices
  for update
  using (true)
  with check (auth.uid() = user_id);

-- 삭제: 본인 기기만 (로그아웃 시 토큰 제거)
create policy "user_devices_delete_own"
  on public.user_devices
  for delete
  using (auth.uid() = user_id);
