# J.A.R.V.I.S · Personal Command Center

A free, self-contained Iron Man style command center. One HTML file, hosted free on GitHub Pages, with live data from Supabase's free tier.

Built on the blueprint from Ray Fu's "Complete Guide to building Jarvis with Claude": a command center on mock data first, then three agents (Scout, Operator, Advisor) that feed it.

## What's in here

| File | What it does |
|---|---|
| `index.html` | The whole dashboard. `MOCK_DATA` at the top holds every number on screen. |
| `supabase.sql` | Creates the two free database tables Jarvis reads and writes. |

## Cost: $0

| Piece | Free tool | Notes |
|---|---|---|
| Hosting | GitHub Pages | Free for public repos. The page itself is public but shows nothing until you sign in. |
| Database | Supabase Free | Free projects pause after about a week with no activity. Open the dashboard regularly or restore from the Supabase dashboard. |
| Voice in | Browser speech recognition | Works in Chrome and Edge. Needs https (GitHub Pages gives you that). |
| Voice out | Browser speech synthesis | Free. Picks a British voice if your computer has one. |
| Jarvis voice (optional) | ElevenLabs free plan, "George" voice | Monthly character limit on the free plan. |

## Step 1 · Run it locally (2 minutes)

1. Download `index.html`.
2. Double click it to open in Chrome.
3. Press **MORNING BRIEF**, or hold **space** and say "what's my schedule".

## Step 2 · Put it online with GitHub Pages (5 minutes)

1. Go to github.com, sign in, click **New repository**.
2. Name it `jarvis`, set it to **Public**, click **Create repository**.
3. Click **uploading an existing file**, drag in `index.html`, `README.md`, `supabase.sql`, click **Commit changes**.
4. Go to **Settings > Pages**. Under Source pick **Deploy from a branch**, branch `main`, folder `/ (root)`, **Save**.
5. Wait a minute. Your Jarvis is live at `https://YOUR-USERNAME.github.io/jarvis/`.

## Step 3 · Supabase (already connected, private)

**Private by default.** The site opens on a sign in screen. Only emails listed in the `jarvis_allowed` table can see anything. All dashboard content lives in Supabase, not in this public file.

This copy is already wired to the Supabase project **jarvis** (Prado & Co. org). The tables from `supabase.sql` are created and the project URL and public anon key are built into `index.html` under `DEFAULTS`.

After you sign in, the top pill shows **LIVE · SECURE**.

To point it at a different project, run `supabase.sql` there and paste the new URL and anon key in **⚙**.

To change anything on screen, edit the `data` JSON in the `jarvis_state` table (Table Editor). Only send the fields you want to change. Everything else falls back to mock data.

**Never** paste the `service_role` key into the dashboard. That key is only for your agents.

## Step 4 · Jarvis voice (optional)

1. Create a free account at elevenlabs.io.
2. Profile > **API Keys** > create a key.
3. In Jarvis, **⚙** > paste the key. Voice ID defaults to George (`JBFqnCBsd6RMkjVDRZzb`).

The key is saved in your browser only, not in the code, so it never ends up in your public repo.

## Step 5 · Give it a brain (next)

Following Ray's order, one at a time:

1. **Scout** (read only). A Claude scheduled task every morning that reads your Calendar, Gmail, TeamSnap and Slack, then writes a summary into `jarvis_state` through the Supabase connector. If a source fails it writes `unavailable`, never a guess.
2. **Operator.** Drafts parent emails, Slack posts and 3v3 reminders into the queue. You approve every one for the first few weeks. Keep an `FAQ.md` of your standard answers so drafts sound like you.
3. **Advisor.** Runs after the Scout, picks the top 3 actions (tier 1 blocking revenue, tier 2 outperforming, tier 3 slow leaks) and keeps the accountability loop of anything open 3+ days.

Right now the voice "brain" is a set of local rules (morning brief, schedule, priorities, operator, tournament, DC Power, ASA, licence, weather, ventures). A free LLM brain can be added later through a Supabase Edge Function so no API key ever sits in the browser.
