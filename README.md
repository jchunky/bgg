# BGG Game Finder

A Ruby script that scrapes and aggregates board game data from
multiple sources to produce a personalized, filterable HTML report
of games worth exploring.

## Data Sources

- **BoardGameGeek (BGG)** -- advanced search results ranked by BGG
  rank, including player-count and playtime breakdowns
- **BGG GeekLists** -- curated community lists (CCC, couples,
  solo)
- **Board Game Oracle (B2GO)** -- availability data
- **Board Game Prices (BGP)** -- Canadian pricing data

Games are merged by a normalized key, ranked, categorized, and
filtered through personal ban/keep lists before rendering.

## Setup

```sh
bundle install
```

## Usage

```sh
ruby bgg.rb
```

This downloads data (cached in `.data/`), aggregates it, and writes
`index.html`.

## Tests

```sh
bundle exec rspec
```

## Project Structure

```
lib/
  config/        # Categories, game lists, downloader wiring
  downloaders/   # Source-specific scrapers (BGG search, GeekLists,
                   B2GO, BGP)
  models/        # Game model with display/filtering logic
  parsers/       # HTML parsers for external sources
  services/      # Aggregation, ranking, view helpers
  utils/         # HTTP fetching, file caching
views/           # ERB template for HTML output
data/            # Personal game lists (played, learned)
```
