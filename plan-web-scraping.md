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

## Task 1: Scrape Board Game 2 Go (b2go)

- **Source:**
  <https://www.boardgame2go.com/>
- **Current:** `data/b2go.txt` is copy-pasted page content, parsed
  in 4-line slices by `Parsers::B2goGame`.
- **Challenge:** Requires login to access the site.
- [ ] Check `robots.txt` for allowed paths.
- [ ] Implement authenticated scraping (store credentials securely,
  e.g. env vars or a `.env` file).
- [ ] Build `Downloaders::B2goData#fetch` to scrape and parse the
  HTML directly, replacing the `File.read` approach.
- [ ] Preserve the existing parser interface so downstream code is
  unaffected.

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
- **BLOCKER:** BGG `robots.txt` explicitly disallows `/plays`.
  Need an alternative approach (BGG API, or accept manual
  copy-paste for this source).
- [ ] Investigate BGG XML API2 as alternative data source.
- [ ] Handle pagination (URL has `/page/1`).
- [ ] Build `Downloaders::TopPlayedData#fetch` to scrape and replace
  `File.read`.
- [ ] Preserve the existing parser interface.

## Task 6: Scrape BGG Replay Stats (replayed)

- **Source:** Per-game stats pages, e.g.
  <https://boardgamegeek.com/playstats/thing/420087>
- **Current:** `data/replayed.txt` is a manually curated list of
  game names (one per line) gathered from individual stats pages.
- **BLOCKER:** BGG `robots.txt` disallows `/play` which
  prefix-matches `/playstats`. Also disallows `/xmlapi`.
  Need an alternative approach or accept manual copy-paste.
- [ ] Investigate BGG XML API2 as alternative data source.
- [ ] Determine which games to check (need a list of BGG thing IDs).
- [ ] Scrape each game's playstats page, extract the relevant
  replay metric.
- [ ] Build a new `Downloaders::ReplayedData` class (or extend
  existing) to automate this.
- [ ] Respect BGG's crawl delay between requests.

## Improvement Opportunities

_(To be filled in as work progresses.)_
