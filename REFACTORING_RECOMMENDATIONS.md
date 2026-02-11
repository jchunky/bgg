# BGG Code Improvement Recommendations

Based on the [Refactoring Guide](https://github.com/jchunky/refactoring_guide), here are the recommended code improvements for the current codebase.

---

## Summary

Many refactorings from the original REFACTORING_PLAN.md have been successfully implemented:
- ✅ Zeitwerk autoloading
- ✅ Paginator module extracted
- ✅ Base class for downloaders
- ✅ Game lists in YAML configuration
- ✅ Parser classes created

The following recommendations identify **remaining opportunities** based on the refactoring guide patterns.

---

## 1. Replace Parallel Arrays with Lookup Table (Config::Categories)

**Guide Pattern:** #1 - Replace Parallel Arrays with Lookup Table

**Problem:** `Config::Categories` uses parallel arrays with positional arguments that require remembering what each position means.

**Current Code (`lib/config/categories.rb`):**
```ruby
CATEGORIES = [
  [:dexterity, 1032, 50, "property"],
  [:campaign, 2822, 50, "property"],
  # ...
]
```

**Recommended:**
```ruby
CATEGORIES = {
  dexterity: { listid: 1032, items_per_page: 50, object_type: "property" },
  campaign:  { listid: 2822, items_per_page: 50, object_type: "property" },
  # ...
}

# Or using Struct for type safety:
CategoryConfig = Struct.new(:prefix, :listid, :items_per_page, :object_type, keyword_init: true)

CATEGORIES = [
  CategoryConfig.new(prefix: :dexterity, listid: 1032, items_per_page: 50, object_type: "property"),
  # ...
]
```

**Benefit:** Self-documenting, eliminates positional errors, allows adding new fields without breaking existing code.

---

## 2. Replace Shovel Chain with Array Composition (Parsers)

**Guide Pattern:** #8 - Replace Shovel Chain with Array Composition

**Problem:** Some parsers use sequential string manipulation or index arithmetic.

**Current Code (`lib/parsers/bgb_game.rb`):**
```ruby
def initialize(data)
  _, _, @name, _, player_count, playtime, rating, weight, preorder, price = data.split("\n")
  # Relies on exact position, fragile
end
```

**Current Code (`lib/parsers/bgo_game.rb`):**
```ruby
def initialize(data)
  parts = data.split("\n")
  case parts.size
  when 5
    @name, player_count, playtime, rating, weight = parts
  when 6
    @name, p2, player_count, playtime, rating, weight = parts
  # ...
end
```

**Recommended:** Use named extraction with fallbacks:
```ruby
def initialize(data)
  lines = data.split("\n")
  @name = extract_name(lines)
  @rating = extract_rating(lines)
  @weight = extract_weight(lines)
  # ...
end

private

def extract_name(lines)
  lines.find { |l| l.match?(/^[A-Z]/) && !l.match?(/^\$/) }
end

def extract_rating(lines)
  lines.find { |l| l.match?(/^\d+\.\d+$/) }&.to_f
end
```

**Benefit:** More resilient to format changes, self-documenting field extraction.

---

## 3. Extract Small Named Methods (Game Model)

**Guide Pattern:** #9 - Extract Small Named Methods

**Problem:** `Game#displayable?` has complex inline logic that could be clearer with named helper methods.

**Current Code (`lib/models/game.rb`):**
```ruby
def displayable?
  return false if weight.round(1) > 2.2
  return false if played?
  return false unless b2go? || snakes? || learned?
  return true if learned?
  return true if keep?
  return false if campaign?
  return false if banned?
  return false unless min_player_count == 1
  true
end
```

**Recommended:**
```ruby
def displayable?
  return false if too_heavy?
  return false if already_played?
  return false unless available_locally?
  return true if prioritized?
  return false if excluded?
  return false unless solo_playable?
  true
end

private

def too_heavy? = weight.round(1) > MAX_WEIGHT
def already_played? = played?
def available_locally? = b2go? || snakes? || learned?
def prioritized? = learned? || keep?
def excluded? = campaign? || banned?
def solo_playable? = min_player_count == 1

MAX_WEIGHT = 2.2
```

**Benefit:** Each condition has a meaningful name, easier to understand and modify filtering criteria.

---

## 4. Replace Nested Conditionals with Case Expression (SnakesData)

**Guide Pattern:** #3 - Replace Nested Conditionals with Case Expression

**Problem:** `SnakesData#match_location?` has multiple `||` conditions that could be clearer.

**Current Code (`lib/downloaders/snakes_data.rb`):**
```ruby
def match_location?(data, line, i)
  line = line.downcase
  return false if line == "blokus 3d"
  return true if data[i + 1] && data[i + 1] == data[i + 2]

  line.match?(/\b\d{1,2}[a-f]\b/) ||
    line.include?("archives") ||
    line.include?("new arrivals") ||
    # ... 8 more conditions
end
```

**Recommended:**
```ruby
LOCATION_PATTERNS = [
  /\b\d{1,2}[a-f]\b/,       # Shelf codes like "3a", "12f"
  /archives/i,
  /new arrivals/i,
  /retired/i,
  /staff picks/i,
]

LOCATION_KEYWORDS = %w[culled mia post prep rpg sickbay].freeze

def match_location?(data, line, i)
  line = line.downcase
  return false if line == "blokus 3d"
  return true if consecutive_duplicates?(data, i)

  matches_location_pattern?(line) || matches_location_keyword?(line)
end

private

def consecutive_duplicates?(data, i)
  data[i + 1] && data[i + 1] == data[i + 2]
end

def matches_location_pattern?(line)
  LOCATION_PATTERNS.any? { |pattern| line.match?(pattern) }
end

def matches_location_keyword?(line)
  LOCATION_KEYWORDS.include?(line)
end
```

**Benefit:** Constants are self-documenting, patterns are easily extensible.

---

## 5. Replace Mutable Accumulator with Functional Composition (Bgg#run)

**Guide Pattern:** #2 - Replace Mutable Accumulator with Functional Composition

**Problem:** `Bgg#run` chains multiple mutations on the games collection.

**Current Code (`bgg.rb`):**
```ruby
def run
  @games = all_games
    .sort_by { |g| -g.votes_per_year }
    .each.with_index(1) { |g, i| g.votes_per_year_rank = i }
    .sort_by { |g| -g.rating_count }
    .each.with_index(1) { |g, i| g.rating_count_rank = i }
    .select(&:displayable?)
    .sort_by { |g| [-g.weight] }
  # ...
end
```

**Recommended:** Extract ranking logic to a dedicated method:
```ruby
def run
  @games = rank_games(all_games)
    .select(&:displayable?)
    .sort_by { |g| -g.weight }

  write_output
end

private

def rank_games(games)
  assign_ranks(games, :votes_per_year, :votes_per_year_rank)
  assign_ranks(games, :rating_count, :rating_count_rank)
  games
end

def assign_ranks(games, sort_attr, rank_attr)
  games
    .sort_by { |g| -g.send(sort_attr) }
    .each.with_index(1) { |g, i| g.send(:"#{rank_attr}=", i) }
end
```

**Benefit:** Ranking logic is reusable and the main flow is clearer.

---

## 6. Replace Module Method with Instance Class (HttpFetcher)

**Guide Pattern:** #7 - Replace Module Method with Instance Class

**Problem:** `Utils::HttpFetcher` uses class methods but would benefit from instance state.

**Current Code (`lib/utils/http_fetcher.rb`):**
```ruby
class HttpFetcher
  def self.fetch_html_data(url)
    Utils::CachedFile.new(url:, extension: "html").read do |content|
      yield Nokogiri::HTML(content)
    end
  end

  def self.fetch_json_data(url)
    Utils::CachedFile.new(url:, extension: "json").read do |content|
      yield JSON.parse(content)
    end
  end
end
```

**Recommended:**
```ruby
class HttpFetcher < Struct.new(:url, keyword_init: true)
  def self.html(url, &block)
    new(url:).fetch_html(&block)
  end

  def self.json(url, &block)
    new(url:).fetch_json(&block)
  end

  def fetch_html
    cached_content("html") { |content| yield Nokogiri::HTML(content) }
  end

  def fetch_json
    cached_content("json") { |content| yield JSON.parse(content) }
  end

  private

  def cached_content(extension, &block)
    Utils::CachedFile.new(url:, extension:).read(&block)
  end
end
```

**Benefit:** Removes duplication, easier to extend with options like custom timeouts or headers.

---

## 7. Duplicate parse_player_count Method (DRY)

**Guide Pattern:** DRY - Don't Repeat Yourself

**Problem:** Both `BgbGame` and `BgoGame` parsers have identical `parse_player_count` methods.

**Current Code (in both parsers):**
```ruby
def parse_player_count(player_count)
  if player_count.include?("-")
    player_count.split("-").map(&:to_i)
  else
    [player_count.to_i, player_count.to_i]
  end
end
```

**Recommended:** Extract to a shared concern or base class:
```ruby
# lib/parsers/concerns/player_count_parser.rb
module Parsers
  module Concerns
    module PlayerCountParser
      def parse_player_count(player_count)
        return [nil, nil] if player_count.blank?
        
        if player_count.include?("-")
          player_count.split("-").map(&:to_i)
        else
          count = player_count.to_i
          [count, count]
        end
      end
    end
  end
end

# In parsers:
class BgbGame
  include Concerns::PlayerCountParser
  # ...
end
```

**Benefit:** Single source of truth for player count parsing logic.

---

## 8. Remove method_missing in Favor of Explicit Delegation

**Guide Pattern:** Explicit over Implicit

**Problem:** `Game` uses `method_missing` for dynamic attribute access, which can mask typos and bugs.

**Current Code (`lib/models/game.rb`):**
```ruby
def method_missing(method_name, *args)
  attribute_name = method_name.to_s.chomp("=").chomp("?").to_sym
  if method_name.to_s.end_with?("=")
    attributes[attribute_name] = args.first
  elsif method_name.to_s.end_with?("?")
    !null?(send(:"#{attribute_name}_rank"))
  else
    attributes[attribute_name]
  end
end
```

**Recommended:** Define known attributes explicitly:
```ruby
KNOWN_ATTRIBUTES = %i[
  name href rank rating rating_count weight year
  min_player_count max_player_count playtime price
  # ... all known attributes
].freeze

KNOWN_ATTRIBUTES.each do |attr|
  define_method(attr) { attributes[attr] }
  define_method(:"#{attr}=") { |value| attributes[attr] = value }
end

# Keep method_missing as fallback for unknown/dynamic attributes
def method_missing(method_name, *args)
  # ... existing logic with warning for unknown attributes
  warn "Unknown attribute accessed: #{method_name}" if ENV["DEBUG"]
  # ...
end

def respond_to_missing?(method_name, include_private = false)
  true # Or check if it's a known pattern
end
```

**Benefit:** IDE autocompletion works, typos are caught, still flexible for new attributes.

---

## 9. Guard Clauses in Parser Validations

**Guide Pattern:** Guard Clauses

**Problem:** Parser `to_game` methods could use clearer guard clauses.

**Current Code (`lib/parsers/b2go_game.rb`):**
```ruby
def to_game
  return nil unless valid?
  Models::Game.new(...)
end
```

**Recommended:** Use early returns consistently across all parsers:
```ruby
def to_game
  return if name.blank?
  return if invalid_format?
  
  Models::Game.new(...)
end

private

def invalid_format?
  @details == "Purchase Only"
end
```

---

## 10. Self-Documenting Constants for Magic Numbers

**Guide Pattern:** #6 - Remove Explanatory Comments by Making Code Self-Documenting

**Problem:** Magic numbers scattered throughout code.

**Examples:**
```ruby
# lib/models/game.rb
weight.round(1) > 2.2  # What is 2.2?

# lib/utils/cached_file.rb
BGG_CRAWL_DELAY = 2    # Good! Already named
CACHE_EXPIRY = 1.year  # Good! Already named

# lib/downloaders/geek_list.rb
(1..8).flat_map { games_for_page(it) }  # Why 8?
```

**Recommended:**
```ruby
# lib/models/game.rb
MAX_COMPLEXITY_WEIGHT = 2.2  # Gateway-friendly weight threshold

# lib/downloaders/geek_list.rb
MAX_PAGES = 8  # GeekList API returns max 8 pages
```

---

## Implementation Priority

### High Value, Low Risk
1. Extract `parse_player_count` to shared concern (DRY)
2. Replace parallel arrays in Categories with hash/struct
3. Extract small named methods in `displayable?`

### Medium Value, Medium Risk
4. Consolidate location matching patterns in SnakesData
5. Refactor HttpFetcher to instance class
6. Add constants for magic numbers

### Lower Priority (Consider Later)
7. Make attribute accessors explicit in Game model
8. Refactor parser initialization to be more resilient

---

## Verification

After each refactoring, verify with:
```bash
bundle exec ruby bgg.rb
```

And check that `index.html` is generated correctly with the expected games.
