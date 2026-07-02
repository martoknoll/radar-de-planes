-- Venue profiles: adds venue location to organizer profiles + photo gallery table.
-- Run once in the Supabase SQL editor.

alter table profiles
  add column if not exists venue_address text,
  add column if not exists venue_lat numeric,
  add column if not exists venue_lng numeric;

create table if not exists venue_photos (
  id            uuid default gen_random_uuid() primary key,
  organizer_id  uuid references profiles(id) on delete cascade not null,
  photo_url     text not null,
  created_at    timestamptz default now()
);

alter table venue_photos enable row level security;

-- Anyone can view venue photos of verified organizers
create policy "venue_photos_public_select" on venue_photos
  for select using (
    exists (
      select 1 from profiles
      where profiles.id = venue_photos.organizer_id
        and profiles.verified = true
    )
  );

-- Organizer can insert their own photos
create policy "venue_photos_owner_insert" on venue_photos
  for insert with check (organizer_id = auth.uid());

-- Organizer can delete their own photos
create policy "venue_photos_owner_delete" on venue_photos
  for delete using (organizer_id = auth.uid());
