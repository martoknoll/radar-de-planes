// Edge Function: resumen semanal de los lunes.
// Para cada usuario: eventos de los próximos 7 días de organizadores que sigue,
// más hasta 3 recomendados (según sus categorías favoritas) de organizadores que NO sigue.
// Se dispara desde pg_cron los lunes a la mañana (ver supabase-email-notifications.sql).

import { createClient } from "jsr:@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const FROM_EMAIL = Deno.env.get("NOTIFY_FROM_EMAIL") ?? "Sonda <onboarding@resend.dev>";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const APP_URL = Deno.env.get("APP_URL") ?? "https://example.com";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

function eventRow(ev: any) {
  return `<li><strong><a href="${APP_URL}/?evento=${ev.id}">${ev.title}</a></strong> — ${ev.organizer} · ${ev.date} ${ev.time}<br>${ev.address}</li>`;
}

async function sendEmail(to: string, subject: string, html: string) {
  await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from: FROM_EMAIL, to, subject, html }),
  });
}

Deno.serve(async (_req) => {
  try {
    const today = new Date();
    const in7days = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);
    const todayStr = today.toISOString().slice(0, 10);
    const in7Str = in7days.toISOString().slice(0, 10);

    const { data: weekEvents, error: eventsError } = await supabase
      .from("events")
      .select("id, title, organizer, category, date, time, address, created_by")
      .gte("date", todayStr)
      .lte("date", in7Str);
    if (eventsError || !weekEvents) return new Response("could not load events", { status: 500 });

    const { data: profiles, error: profilesError } = await supabase
      .from("profiles")
      .select("id");
    if (profilesError || !profiles) return new Response("could not load profiles", { status: 500 });

    const { data: users, error: usersError } = await supabase.auth.admin.listUsers();
    if (usersError) return new Response("could not list users", { status: 500 });
    const emailById = new Map(users.users.map((u) => [u.id, u.email]));

    let sent = 0;
    for (const profile of profiles) {
      const email = emailById.get(profile.id);
      if (!email) continue;

      const { data: follows } = await supabase
        .from("follows")
        .select("followed_id")
        .eq("follower_id", profile.id);
      const followedIds = new Set((follows ?? []).map((f) => f.followed_id));

      const { data: prefs } = await supabase
        .from("category_preferences")
        .select("category_id")
        .eq("user_id", profile.id);
      const categories = new Set((prefs ?? []).map((p) => p.category_id));

      const followedEvents = weekEvents.filter((ev) => followedIds.has(ev.created_by));
      const recommended = weekEvents
        .filter((ev) => !followedIds.has(ev.created_by) && categories.has(ev.category))
        .slice(0, 3);

      if (!followedEvents.length && !recommended.length) continue;

      const html = `
        ${followedEvents.length ? `<h2>Esta semana de la gente que seguís</h2><ul>${followedEvents.map(eventRow).join("")}</ul>` : ""}
        ${recommended.length ? `<h2>Recomendados para vos</h2><ul>${recommended.map(eventRow).join("")}</ul>` : ""}
        <p><a href="${APP_URL}">Ver todo en Sonda</a></p>
      `;
      await sendEmail(email, "Tu resumen semanal de planes en Sonda", html);
      sent++;
    }

    return new Response(JSON.stringify({ sent }), { headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(String(err), { status: 500 });
  }
});
