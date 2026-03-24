# Plan: Dead Code Cleanup

## Commit 1: Remove dead parsers, concern, and specs

The BgoGame, BgbGame, and TopPlayedGame parsers are never called —
their downloaders were commented out and then removed. The
PlayerCountParser concern is only used by BgoGame and BgbGame.

- [ ] Delete `lib/parsers/bgo_game.rb`
- [ ] Delete `lib/parsers/bgb_game.rb`
- [ ] Delete `lib/parsers/top_played_game.rb`
- [ ] Delete `lib/parsers/concerns/player_count_parser.rb`
- [ ] Delete `spec/parsers/bgo_game_spec.rb`
- [ ] Delete `spec/parsers/bgb_game_spec.rb`
- [ ] Delete `spec/parsers/top_played_game_spec.rb`
- [ ] Remove commented-out downloader lines in `config/downloaders.rb`

## Commit 2: Remove RobotsChecker and robotstxt gem

RobotsChecker was built for the scraping plan but is never called.
The robotstxt gem is only used by it.

- [ ] Delete `lib/utils/robots_checker.rb`
- [ ] Remove `robotstxt` from Gemfile
- [ ] Remove `require "robotstxt"` from `bgg.rb`
- [ ] `bundle install` to update Gemfile.lock

## Commit 3: Remove stale model/view references

No active downloader populates bgb_price, offer_count, or replayed.
Clean up the dead paths.

- [ ] `game.rb`: change `normalized_price` to just use `price`
- [ ] `views/bgg.erb`: remove `.replayed` CSS class
- [ ] `views/bgg.erb`: remove `offer_count` reference
- [ ] `spec/models/game_spec.rb`: remove bgb_price and bgb? specs

## Commit 4: Delete completed plan file

- [ ] Delete `plan-web-scraping.md`
- [ ] Delete this plan file

## Improvement opportunities

(none yet)
