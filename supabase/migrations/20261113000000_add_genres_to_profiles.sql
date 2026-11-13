-- 프로필 장르(밴드 취향) 컬럼 추가.
-- Genre enum의 name 문자열 배열로 저장한다. (sessions 컬럼과 동일한 방식)
alter table public.profiles
  add column if not exists genres text[];
