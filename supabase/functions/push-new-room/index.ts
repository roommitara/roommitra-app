// RoomMitra: naya room approve hone par us shehar ke users ko push bhejta hai.
// Sirf admin chala sakta hai. Secret: FCM_SERVICE_ACCOUNT (Firebase service account JSON).
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const json = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...cors, "Content-Type": "application/json" } });

const b64url = (d: ArrayBuffer | string) => {
  const bytes = typeof d === "string" ? new TextEncoder().encode(d) : new Uint8Array(d);
  let s = "";
  bytes.forEach((c) => (s += String.fromCharCode(c)));
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
};

async function accessToken(sa: { client_email: string; private_key: string }) {
  const now = Math.floor(Date.now() / 1000);
  const head = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const pem = sa.private_key.replace(/-----[A-Z ]+-----/g, "").replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8", der, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"]);
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(`${head}.${claim}`));
  const jwt = `${head}.${claim}.${b64url(sig)}`;
  const r = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const j = await r.json();
  if (!j.access_token) throw new Error("fcm auth failed");
  return j.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const authHeader = req.headers.get("Authorization") ?? "";
    const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: isAdmin } = await userClient.rpc("is_admin");
    if (isAdmin !== true) return json({ error: "admin only" }, 403);

    const { listing_id } = await req.json();
    if (!listing_id) return json({ error: "listing_id missing" }, 400);

    const db = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: l } = await db.from("room_listings")
      .select("id, owner_id, title, city, locality, monthly_rent, status")
      .eq("id", listing_id).maybeSingle();
    if (!l || l.status !== "approved") return json({ skipped: "not approved" });

    // ek kamre ke liye sirf ek baar
    const { error: dup } = await db.from("push_log").insert({ listing_id });
    if (dup) return json({ skipped: "already sent" });

    const { data: tokens } = await db.from("device_tokens")
      .select("token, user_id, lang").eq("city", l.city).neq("user_id", l.owner_id);
    if (!tokens || tokens.length === 0) return json({ sent: 0 });

    const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT");
    if (!saRaw) return json({ error: "FCM_SERVICE_ACCOUNT secret missing" }, 500);
    const sa = JSON.parse(saRaw);
    const at = await accessToken(sa);

    const where = l.locality ? `${l.locality}, ${l.city}` : l.city;
    const rent = l.monthly_rent ? `₹${l.monthly_rent}` : "";
    const rows: Record<string, unknown>[] = [];
    let sent = 0;
    const dead: string[] = [];

    await Promise.all(tokens.map(async (tk) => {
      const hi = tk.lang !== "en";
      const title = hi ? `नया कमरा: ${l.city}` : `New room in ${l.city}`;
      const body = `${l.title} · ${where}${rent ? " · " + rent + (hi ? "/माह" : "/mo") : ""}`;
      const r = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
        method: "POST",
        headers: { Authorization: `Bearer ${at}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          message: {
            token: tk.token,
            notification: { title, body },
            data: { kind: "new_room", listing_id: String(l.id) },
            android: { priority: "HIGH", notification: { color: "#1B8A5A" } },
          },
        }),
      });
      if (r.ok) sent++;
      else if (r.status === 404 || r.status === 400) dead.push(tk.token);
    }));

    if (dead.length) await db.from("device_tokens").delete().in("token", dead);

    // ऐप के अंदर वाली नोटिफिकेशन लिस्ट में भी दिखे (हर यूज़र की एक)
    const seen = new Set<string>();
    for (const tk of tokens) {
      if (seen.has(tk.user_id)) continue;
      seen.add(tk.user_id);
      rows.push({
        user_id: tk.user_id, kind: "new_room", listing_id: l.id,
        title_hi: `नया कमरा: ${l.city}`, title_en: `New room in ${l.city}`,
        body_hi: `${l.title} · ${where}`, body_en: `${l.title} · ${where}`,
      });
    }
    await db.from("notifications").insert(rows);

    return json({ sent, total: tokens.length });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
