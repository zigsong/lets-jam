// notifications INSERT Webhook을 받아 FCM 푸쉬를 발송하는 Edge Function.
//
// 흐름: comments INSERT (트리거 create_comment_notification)
//   → notifications INSERT → Database Webhook → 이 함수 → FCM HTTP v1
//
// 필요한 Secrets (supabase secrets set):
//   - FIREBASE_SERVICE_ACCOUNT : Firebase 서비스 계정 JSON 전체 (문자열)
//   - WEBHOOK_SECRET           : Webhook 호출 검증용 임의 문자열
// 자동 주입: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { createClient } from "npm:@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@5";

interface NotificationRecord {
  id: string;
  recipient_id: string;
  actor_id: string | null;
  type: string;
  post_id: string | null;
  comment_id: string | null;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: NotificationRecord | null;
}

const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!);
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// ── FCM OAuth2 액세스 토큰 발급 (서비스 계정 JWT → access_token) ──
let cachedToken: { value: string; exp: number } | null = null;

async function getAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.exp > now + 60) return cachedToken.value;

  const key = await importPKCS8(serviceAccount.private_key, "RS256");
  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setSubject(serviceAccount.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await res.json();
  if (!res.ok) throw new Error(`액세스 토큰 발급 실패: ${JSON.stringify(json)}`);

  cachedToken = { value: json.access_token, exp: now + json.expires_in };
  return json.access_token;
}

// ── 단일 기기로 FCM 발송. 무효 토큰이면 token 문자열 반환(정리 대상) ──
async function sendToToken(
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<{ invalid: boolean; status: number; detail: string }> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        },
      }),
    },
  );

  const text = await res.text();
  if (res.ok) return { invalid: false, status: res.status, detail: text.slice(0, 200) };

  let status: string | undefined;
  try {
    const err = JSON.parse(text);
    status = err?.error?.details?.[0]?.errorCode ?? err?.error?.status;
  } catch (_) { /* noop */ }
  const invalid = res.status === 404 ||
    status === "UNREGISTERED" ||
    status === "INVALID_ARGUMENT";
  return { invalid, status: res.status, detail: text.slice(0, 300) };
}

Deno.serve(async (req) => {
  // Webhook 검증
  if (req.headers.get("x-webhook-secret") !== Deno.env.get("WEBHOOK_SECRET")) {
    return new Response("Unauthorized", { status: 401 });
  }

  try {
    const payload = (await req.json()) as WebhookPayload;
    const n = payload.record;

    // 댓글 알림만 처리
    if (!n || payload.type !== "INSERT" || n.type !== "comment") {
      return new Response("skip", { status: 200 });
    }

    // 수신자 기기 토큰
    const { data: devices } = await supabase
      .from("user_devices")
      .select("fcm_token")
      .eq("user_id", n.recipient_id);

    if (!devices || devices.length === 0) {
      return new Response("no devices", { status: 200 });
    }

    // 문구 구성: 작성자 닉네임 + 댓글 내용
    const [{ data: actor }, { data: comment }] = await Promise.all([
      n.actor_id
        ? supabase.from("profiles").select("nickname").eq("id", n.actor_id)
          .maybeSingle()
        : Promise.resolve({ data: null }),
      n.comment_id
        ? supabase.from("comments").select("content").eq("id", n.comment_id)
          .maybeSingle()
        : Promise.resolve({ data: null }),
    ]);

    const nickname = actor?.nickname ?? "누군가";
    const content = (comment?.content ?? "").trim();
    const title = `${nickname}님이 댓글을 남겼어요`;
    const body = content.length > 100 ? `${content.slice(0, 100)}…` : content;

    const data: Record<string, string> = {
      type: "comment",
      notification_id: n.id,
      post_id: n.post_id ?? "",
      // 탭 시 PostDetailScreen(userId)에 쓰이는 게시글 작성자 = 수신자
      post_user_id: n.recipient_id,
    };

    const accessToken = await getAccessToken();
    const invalidTokens: string[] = [];
    const results: Array<{ status: number; detail: string }> = [];
    await Promise.all(
      devices.map(async (d) => {
        const r = await sendToToken(
          accessToken,
          d.fcm_token,
          title,
          body || "새 댓글이 달렸어요",
          data,
        );
        results.push({ status: r.status, detail: r.detail });
        if (r.invalid) invalidTokens.push(d.fcm_token);
      }),
    );

    // 무효 토큰 정리
    if (invalidTokens.length > 0) {
      await supabase.from("user_devices").delete().in(
        "fcm_token",
        invalidTokens,
      );
    }

    return new Response(
      JSON.stringify({
        sent: devices.length - invalidTokens.length,
        results,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("send-push 에러:", e);
    return new Response("error", { status: 500 });
  }
});
