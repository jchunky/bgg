# Plan: Remove Legacy B2GO Parser + Extract Value Objects

## Tasks

1. **Remove legacy `Parsers::B2goGame` and its specs** — dead code,
   nothing references it since the switch to the JSON API in `B2goData`.
2. **Extract `PlayerCount` value object** — wrap `minplayers`/`maxplayers`
   into a `Data.define` with `#to_s`, `#range`, `#min`, `#max`,
   `#one_player?`, `#two_player?`, `#soloable?`. Move logic out of
   Game's `PlayerCount` and `GameData` concerns.
3. **Extract `Weight` value object** — wrap the numeric weight with
   override resolution into `Data.define(:value)` with `#displayable?`
   (≤ 2.2 check), `#round`, delegation to Float. Simplifies Game's
   `Customize` and `Display` concerns.

Each task is a separate commit.

## Improvement Opportunities

_(discovered during work)_
