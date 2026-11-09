-- 댓글 알림 푸쉬 Webhook
-- notifications INSERT(type='comment') 시 send-push Edge Function을 호출한다.
--
-- ⚠️ webhook secret은 git에 두지 않는다. 아래 트리거 함수는 Supabase Vault의
--    'push_webhook_secret'을 읽는다. 최초 1회 아래를 실행해 Vault에 등록해야 한다
--    (edge function의 WEBHOOK_SECRET env와 동일한 값):
--
--    select vault.create_secret('<WEBHOOK_SECRET 값>', 'push_webhook_secret');

create extension if not exists pg_net;

create or replace function public.notify_push_on_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_secret text;
begin
  if new.type = 'comment' then
    select decrypted_secret into v_secret
    from vault.decrypted_secrets where name = 'push_webhook_secret';

    perform net.http_post(
      url := 'https://rihmgxyfsfqdnmiltdpo.supabase.co/functions/v1/send-push',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-webhook-secret', v_secret
      ),
      body := jsonb_build_object(
        'type', 'INSERT',
        'table', 'notifications',
        'record', to_jsonb(new)
      )
    );
  end if;
  return new;
end;
$$;

drop trigger if exists on_notification_send_push on public.notifications;
create trigger on_notification_send_push
  after insert on public.notifications
  for each row execute function public.notify_push_on_notification();
