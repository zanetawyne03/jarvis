-- JARVIS · Supabase setup (free tier)
-- Paste this whole file into Supabase > SQL Editor > New query > Run.

-- 1. The dashboard state. One row (id = 'main') holds a JSON object shaped
--    like MOCK_DATA in index.html. Any field you put here overrides the mock.
create table if not exists public.jarvis_state (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- 2. A log of everything you say to Jarvis and what it answers.
create table if not exists public.jarvis_log (
  id bigint generated always as identity primary key,
  role text not null check (role in ('user','jarvis')),
  text text not null,
  created_at timestamptz not null default now()
);

-- 3. Security. The browser uses the public anon key, so lock things down:
--    the dashboard can READ state and ADD log lines, nothing else.
--    Your agents (Scout / Advisor) write state with the service role key,
--    which bypasses RLS and must never go in index.html.
alter table public.jarvis_state enable row level security;
alter table public.jarvis_log enable row level security;

drop policy if exists "dashboard reads state" on public.jarvis_state;
create policy "dashboard reads state" on public.jarvis_state
  for select to anon using (true);

drop policy if exists "dashboard writes log" on public.jarvis_log;
create policy "dashboard writes log" on public.jarvis_log
  for insert to anon with check (char_length(text) < 2000);

-- 4. Seed a first live row so you can watch the dashboard flip to LIVE.
insert into public.jarvis_state (id, data) values (
  'main',
  '{
    "tournament": { "teams": 31, "revenue": 4650 },
    "scout": { "lastRun": "Supabase test", "inbox": { "unread": 9, "flagged": 2, "parents": 3 } }
  }'::jsonb
)
on conflict (id) do update set data = excluded.data, updated_at = now();
