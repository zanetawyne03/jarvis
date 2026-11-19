-- JARVIS · Supabase setup (free tier, private)
-- Paste into Supabase > SQL Editor > New query > Run.
-- Then add your email at the bottom and set Auth > URL Configuration
-- Site URL to your GitHub Pages address.

create table if not exists public.jarvis_state (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.jarvis_log (
  id bigint generated always as identity primary key,
  role text not null check (role in ('user','jarvis')),
  text text not null,
  created_at timestamptz not null default now()
);
-- Who may use Jarvis. No policies, so it can't be read or changed from the web.
create table if not exists public.jarvis_allowed (email text primary key);

alter table public.jarvis_state enable row level security;
alter table public.jarvis_log enable row level security;
alter table public.jarvis_allowed enable row level security;

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;
create or replace function private.is_jarvis_owner()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.jarvis_allowed a
                 where a.email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;
revoke all on function private.is_jarvis_owner() from public, anon;
grant execute on function private.is_jarvis_owner() to authenticated;

-- Signed in AND on the allowlist only. Nothing is readable without signing in.
revoke all on public.jarvis_state from anon;
revoke all on public.jarvis_log from anon;
grant select on public.jarvis_state to authenticated;
grant insert on public.jarvis_log to authenticated;
create policy "owner reads state" on public.jarvis_state
  for select to authenticated using ((select private.is_jarvis_owner()));
create policy "owner writes log" on public.jarvis_log
  for insert to authenticated with check ((select private.is_jarvis_owner()) and char_length(text) < 2000);

-- Your agents (Scout / Advisor) write jarvis_state with the service role key,
-- which must never go in index.html.

-- Give yourself access (use your own email):
-- insert into public.jarvis_allowed (email) values ('you@example.com');
