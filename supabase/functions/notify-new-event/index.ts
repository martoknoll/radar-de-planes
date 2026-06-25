// Edge Function: notifica por mail a los seguidores cuando un organizador publica un evento nuevo.
// Se llama desde un trigger de Postgres (ver supabase-email-notifications.sql) vía pg_net,
// pasando el id del evento recién insertado.

import { createClient } from "jsr:@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const FROM_EMAIL = Deno.env.get("NOTIFY_FROM_EMAIL") ?? "Sonda <onboarding@resend.dev>";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const APP_URL = Deno.env.get("APP_URL") ?? "https://example.com";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

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

Deno.serve(async (req) => {
  try {
    const { event_id } = await req.json();
    if (!event_id) return new Response("missing event_id", { status: 400 });

    const { data: event, error: eventError } = await supabase
      .from("events")
      .select("id, title, organizer, date, time, address, created_by")
      .eq("id", event_id)
      .single();
    if (eventError || !event || !event.created_by) {
      return new Response("event not found", { status: 404 });
    }

    const { data: followers, error: followersError } = await supabase
      .from("follows")
      .select("follower_id")
      .eq("followed_id", event.created_by);
    if (followersError || !followers?.length) {
      return new Response("no followers", { status: 200 });
    }

    const { data: users, error: usersError } = await supabase.auth.admin.listUsers();
    if (usersError) return new Response("could not list users", { status: 500 });

    const followerIds = new Set(followers.map((f) => f.follower_id));
    const recipients = users.users.filter((u) => followerIds.has(u.id) && u.email);

    await Promise.all(
      recipients.map((u) =>
        sendEmail(
          u.email!,
          `Nuevo plan de ${event.organizer}: ${event.title}`,
          `<p><strong>${event.organizer}</strong>, a quien seguís, publicó un nuevo plan.</p>
           <h2>${event.title}</h2>
           <p>${event.date} · ${event.time}<br>${event.address}</p>
           <p><a href="${APP_URL}">Ver en Sonda</a></p>`,
        ),
      ),
    );

    return new Response(JSON.stringify({ sent: recipients.length }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(String(err), { status: 500 });
  }
});
