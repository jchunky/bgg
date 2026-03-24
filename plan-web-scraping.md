# Plan: Replace Manual Copy-Paste with Web Scraping

All current "downloaders" for local store/site data simply read
from `data/*.txt` files that are manually copy-pasted from web pages.
The goal is to scrape each site directly, respecting `robots.txt`.

## Technology Choices

- **`robotstxt` gem** -- parse and check `robots.txt` before
  scraping any path.
- **`ferrum` gem** -- headless Chrome via CDP for JS-rendered pages
  and login-gated sites (b2go). Lightweight, no WebDriver needed.
- **Nokogiri** -- already in use; parse HTML from static pages or
  from Ferrum's `page.body` output.

## Shared Infrastructure

- [x] Add `robotstxt` and `ferrum` to the Gemfile.
- [x] Create a `Utils::RobotsChecker` that fetches and caches a
  site's `robots.txt`, exposes an `allowed?(url)` method. Every
  scraper calls this before fetching.
- [x] Create a `Utils::BrowserSession` (or similar) wrapping Ferrum
  for shared headless Chrome lifecycle (boot once, reuse across
  scrapers that need it).

## Task 1: Scrape Board Game 2 Go (b2go) -- DONE

- **Source:** JSON API at `backend.boardgame2go.com/api/v1/products/`
- **Finding:** No robots.txt, no auth needed (guest access). The
  site uses a clean REST API with offset/limit pagination.
- [x] Check `robots.txt` -- none exists (404).
- [x] No login needed -- API is publicly accessible.
- [x] Replaced `File.read` with API-based fetching in
  `Downloaders::B2goData`. Uses `HttpFetcher.json` with pagination.
- [x] Downstream interface preserved -- still returns
  `Models::Game` with `name`, `b2go`, `b2go_price`.

## Task 2: Scrape Board Game Bliss via Board Game Oracle (bgb)

- **Source:**
  <https://www.boardgameoracle.com/en-CA/store/GJYrR6CW/board-game-bliss/offers?f.type=boardgame>
- **Current:** `data/bgb.txt` is copy-pasted, parsed by
  `Parsers::BgbGame` splitting on double newlines.
- [ ] Check `robots.txt` for boardgameoracle.com.
- [ ] Scrape the page (handle pagination if present).
- [ ] Build `Downloaders::BgbData#fetch` to replace `File.read`.
- [ ] Preserve the existing parser interface.

## Task 3: Scrape Board Game Oracle search (bgo)

- **Source:**
  <https://www.boardgameoracle.com/en-CA/boardgame/search?f.type=boardgame>
- **Current:** `data/bgo.txt` is copy-pasted, parsed by
  `Parsers::BgoGame` splitting on double newlines.
- [ ] Check `robots.txt` (same domain as Task 2).
- [ ] Scrape the page (handle pagination if present).
- [ ] Build `Downloaders::BgoData#fetch` to replace `File.read`.
- [ ] Preserve the existing parser interface.

## Task 4: Scrape Snakes & Lattes library (snakes)

- **Source:**
  <https://live.snakesandlattes.com/library/?location=college>
- **Current:** `data/snakes.txt` is copy-pasted, parsed by
  `Parsers::SnakesGame` with nav-header stripping and chunking.
- [ ] Check `robots.txt` for live.snakesandlattes.com.
- [ ] Determine if the page is JS-rendered (likely, given "live."
  subdomain) -- may need a headless browser.
- [ ] Build `Downloaders::SnakesData#fetch` to scrape and replace
  `File.read`.
- [ ] Preserve the existing parser interface.

## Task 5: Scrape BGG Top Played Games (top_played_games)

- **Source:**
  <https://boardgamegeek.com/plays/bygame/subtype/All/start/2026-02-21/end/2026-03-23/page/1>
- **Current:** `data/top_played_games.txt` is copy-pasted, parsed
  line-by-line by `Parsers::TopPlayedGame`.
- **BLOCKED -- keep manual copy-paste.** BGG `robots.txt`
  disallows `/plays`. No API equivalent exists on `api.geekdo.com`
  (404) or XML API2 (per-user only, not aggregated). Cloudflare
  Turnstile also blocks headless browsers.

## Task 6: Scrape BGG Replay Stats (replayed)

- **Source:** Per-game stats pages, e.g.
  <https://boardgamegeek.com/playstats/thing/420087>
- **Current:** `data/replayed.txt` is a manually curated list of
  game names (one per line) gathered from individual stats pages.
- **BLOCKED -- keep manual copy-paste.** BGG `robots.txt`
  disallows `/play` (prefix-matches `/playstats`). No API
  equivalent found. Cloudflare Turnstile blocks headless browsers.

## Improvement Opportunities

_(To be filled in as work progresses.)_
