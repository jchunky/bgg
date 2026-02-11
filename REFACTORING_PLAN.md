# BGG Refactoring Plan

Based on the [Refactoring Guide](https://github.com/jchunky/refactoring_guide), here are the recommended code improvements to implement as separate commits.

---

## 1. Replace Manual Requires with Zeitwerk Autoloading

**Principle:** Leverage Standard Library & Idioms

**Problem:** Manual `require_relative` statements in `lib/config/downloaders.rb` and `Dir["lib/**/*.rb"].each` in `bgg.rb` are fragile and order-dependent.

**Solution:** 
- Add `zeitwerk` gem to Gemfile
- Create `lib/loader.rb` to configure Zeitwerk
- Replace manual requires with autoloading
- Restructure files to follow Zeitwerk naming conventions

**Files to change:**
- `Gemfile`
- `bgg.rb`
- `lib/loader.rb` (new)
- `lib/config/downloaders.rb`
- Move `lib/utils/utils.rb` → `lib/utils.rb`
- Move `lib/utils/cached_file.rb` → `lib/cached_file.rb`

---

## 2. DRY: Extract Paginator Module

**Principle:** DRY (Don't Repeat Yourself)

**Problem:** `GameSearch`, `CategoryGames`, and `GeekList` all have nearly identical `content_for_pages` methods with the same pagination pattern.

**Solution:** Extract a shared `Paginator` module that can be included in each downloader.

**Files to change:**
- `lib/downloaders/paginator.rb` (new)
- `lib/downloaders/game_search.rb`
- `lib/downloaders/category_games.rb`
- `lib/downloaders/geek_list.rb`

---

## 3. Standardize Downloader Interface with Base Class

**Principle:** Consistency & Polymorphism

**Problem:** Some downloaders use `Struct` inheritance, others are plain classes. Interface varies.

**Solution:** Create a `Downloaders::Base` class that defines the required interface (`prefix`, `listid`, `games`).

**Files to change:**
- `lib/downloaders/base.rb` (new)
- `lib/downloaders/game_search.rb`
- `lib/downloaders/category_games.rb`
- `lib/downloaders/geek_list.rb`
- `lib/downloaders/b2go_data.rb`
- `lib/downloaders/bgb_data.rb`
- `lib/downloaders/snakes_data.rb`

---

## 4. Extract Game Lists to Configuration Files

**Principle:** Separation of Concerns

**Problem:** `keep?`, `banned_game?`, `banned_series?`, `b2go?`, `ccc?`, `weight`, `child?`, `skirmish?` all have hardcoded arrays of game names embedded in methods.

**Solution:** 
- Create `config/game_lists.yml` with all game lists
- Create `lib/config/game_lists.rb` to load the YAML
- Update Game model to use the configuration

**Files to change:**
- `config/game_lists.yml` (new)
- `lib/config/game_lists.rb` (new)
- `lib/models/game.rb`

---

## 5. Encapsulation: Move Display Logic to Game Model

**Principle:** Encapsulation & Rich Domain Object Pattern

**Problem:** `Bgg#display_game?` contains complex filtering logic that belongs with the `Game` object.

**Solution:** Move the filtering logic into `Game#displayable?(criteria)` method.

**Files to change:**
- `lib/models/game.rb`
- `bgg.rb`

---

## 6. Guard Clauses for Display Logic

**Principle:** Guard Clauses & Explicit over Implicit

**Problem:** In `Bgg#display_game?`, the commented-out code and multiple `return false unless` statements are hard to follow.

**Solution:** Use clearer guard clauses with positive conditions and helper methods like `too_heavy?`, `available_somewhere?`, `solo_playable?`.

**Files to change:**
- `lib/models/game.rb`

---

## 7. Replace method_missing with Explicit Accessors

**Principle:** Explicit over Implicit

**Problem:** `Game` uses `method_missing` for dynamic attributes, which hides the API and can mask bugs.

**Solution:** Define known attributes explicitly using `define_method`, keeping `method_missing` as fallback for unknown attributes.

**Files to change:**
- `lib/models/game.rb`

---

## 8. Self-Documenting Composition for category_label

**Principle:** Self-Documenting Composition Pattern

**Problem:** `category_label` method builds a complex result through mutation and imperative logic.

**Solution:** Use functional composition with array concatenation and `compact.sort.join`.

**Files to change:**
- `lib/models/game.rb`

---

## 9. Create Parser Classes (Struct-Based Value Wrapper Pattern)

**Principle:** Struct-Based Value Wrapper Pattern

**Problem:** Each downloader has a `build_game` method that mixes parsing logic with Game construction.

**Solution:** Create separate parser classes for each data source that encapsulate the parsing logic.

**Files to change:**
- `lib/parsers/game_parser.rb` (new - base class)
- `lib/parsers/b2go_game_parser.rb` (new)
- `lib/parsers/bgb_game_parser.rb` (new)
- `lib/parsers/category_game_parser.rb` (new)
- `lib/parsers/geek_list_game_parser.rb` (new)
- `lib/parsers/snakes_game_parser.rb` (new)
- Update downloaders to use parsers

---

## 10. Use dig/fetch for Safer Hash Access

**Principle:** Leverage Standard Library

**Problem:** Direct hash access like `row["item"]["href"]` can fail silently or raise unclear errors.

**Solution:** Use `dig` for nested access and `fetch` with defaults in parser classes.

**Files to change:**
- `lib/parsers/category_game_parser.rb`
- `lib/parsers/geek_list_game_parser.rb`
- `lib/downloaders/game_search.rb`

---

## 11. Fix Silent Error Handling with NullGame

**Principle:** Explicit over Implicit

**Problem:** `BgbData#build_game` has `rescue StandardError => OpenStruct.new` which silently swallows errors.

**Solution:** 
- Create a `NullGame` class that provides safe defaults
- Log errors explicitly when parsing fails

**Files to change:**
- `lib/models/null_game.rb` (new)
- `lib/parsers/bgb_game_parser.rb`

---

## Implementation Order

Each step should be implemented and committed separately:

```
1. Zeitwerk autoloading
2. DRY: Paginator module
3. Base class for downloaders
4. Game lists configuration
5. Move display logic to Game model
6. Guard clauses for display logic
7. Explicit attribute accessors
8. Self-documenting category_label
9. Parser classes
10. Safe hash access (dig/fetch)
11. NullGame error handling
```

Run `bundle exec ruby bgg.rb` after each step to verify the refactoring works.
