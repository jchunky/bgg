# BGG Code Improvement Plan

## 1. Fix `Game#merge` Bug
**Problem:** The merge conflict resolution block `{ |_, a, b| null?(a) ? b : a }` is passed to `Game.new`, not to `Hash#merge`, so merge conflict resolution is silently ignored.
**Fix:** Call `Hash#merge` with the block first, then pass the result to `Game.new`.

## 2. Add `respond_to_missing?` to `Game`
**Problem:** `Game` implements `method_missing` but lacks the matching `respond_to_missing?`. This breaks `respond_to?`, `method(:name)`, etc.
**Fix:** Add `respond_to_missing?` that mirrors the `method_missing` logic.

## 3. Fix Dead `bad_cost_per_play` Reference in ERB Template
**Problem:** `bad_game = bad_conditions[:bad_cost_per_play]` references a key that doesn't exist in `bad_conditions`, so `bad_game` is always nil.
**Fix:** Remove the dead code since it serves no purpose.

## 4. Extract File I/O from Game Constants to Lazy Class Methods
**Problem:** `Game` reads 3 text files as constants at class load time, coupling the model to the filesystem and making testing harder.
**Fix:** Convert `LEARNED`, `REPLAYED`, `PLAYED` from constants to lazily-loaded class methods.

## 5. DRY Up File-Based Downloaders with a Common Base
**Problem:** `B2goData`, `BgbData`, `BgoData`, `SnakesData`, `TopPlayedData` all follow read-split-parse pattern.
**Fix:** Extract a `FileBasedDownloader` base class that handles the common pattern.

## 6. Extract Services from `Bgg`
**Problem:** `bgg.rb` handles aggregation, ranking, formatting, and output all in one class.
**Fix:** Extract `GameAggregator`, `GameRanker` services, and `ViewHelpers` module.

## 7. Convert Struct-Based Classes to Regular Classes / Data.define
**Problem:** `CategoryGames`, `GameSearch`, `GeekList` inherit from `Struct.new(...)` inconsistently with the rest of the codebase. `HttpFetcher` and `CachedFile` also use Struct.
**Fix:** Use `Data.define` for truly immutable value objects (e.g., `HttpFetcher`). Convert mutable ones to regular classes with keyword args.

## 8. Minor Cleanups
- Fix `category_label` memoization (`||=` → memoization is correct but `=` in method definition is redundant)
- Extract hardcoded strings in `snakes_data.rb` `match_location?` to constants
- Add specificity to rescue in `Parseable#parse`
