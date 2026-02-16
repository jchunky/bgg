# AI Comprehension Code Review

## Overview

This document critiques the current codebase against the AI-Friendly Ruby Guidelines and provides rewritten code that is optimized for AI comprehension.

---

## Part 1: Critique of Current Code

### 1. `lib/models/game.rb` - Critical Issues

#### Issue 1: `method_missing` without `respond_to_missing?`

```ruby
# ❌ Current code - AI cannot determine what methods exist
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

**Problems:**
- AI has no way to know what methods are valid
- No `respond_to_missing?` defined
- No explicit attribute list to discover available methods
- Dynamic `?` predicate methods are completely invisible

#### Issue 2: Heavy use of `concerning` blocks

```ruby
concerning :Categories do
  # ...methods scattered here
end

concerning :Attributes do
  # ...more methods here
end
```

**Problems:**
- `concerning` is Rails-specific and fragments class definition
- AI must mentally stitch together the class from multiple blocks
- Harder to see the full interface of the class at a glance

#### Issue 3: Magic numbers without constants

```ruby
# ❌ Current code
return false if weight.round(1) > 2.2
```

**Problem:** AI cannot understand the significance of `2.2` or find where this threshold is defined.

#### Issue 4: Implicit `super` calls in dynamic context

```ruby
# ❌ Current code
def weight = Config::GameLists.weight_overrides.fetch(name, super)
def min_player_count
  return 1 if one_player_game_1?
  return 1 if one_player_game_2?
  super  # What is super? method_missing!
end
```

**Problem:** `super` calls into `method_missing`, making control flow invisible to AI.

#### Issue 5: No documentation on complex business logic

```ruby
def displayable?
  return false if weight.round(1) > 2.2
  return false if played?
  return false unless b2go? || snakes? || learned?
  # ... many more conditions
end
```

**Problem:** AI cannot understand the business rules or why these conditions matter.

---

### 2. `lib/parsers/bgo_game.rb` - Issues

#### Issue 1: Complex parsing with magic indices

```ruby
# ❌ Current code
case parts.size
when 5
  @name, player_count, playtime, rating, weight = parts
when 6
  @name, p2, player_count, playtime, rating, weight = parts
when 9
  @name, p2, _, _, price, player_count, playtime, rating, weight = parts
```

**Problems:**
- Magic numbers (5, 6, 9) with no explanation
- Variable `p2` is cryptically named
- No documentation of expected data formats

---

### 3. `lib/parsers/concerns/parseable.rb` - Issues

#### Issue 1: Silent error swallowing

```ruby
# ❌ Current code
def parse(data)
  new(data).to_game
rescue StandardError
  nil
end
```

**Problem:** AI cannot understand what errors might occur or why they're being ignored.

---

## Part 2: Rewritten AI-Friendly Code

### `lib/models/game.rb` (Rewritten)

```ruby
# frozen_string_literal: true

module Models
  # Represents a board game with attributes from various data sources.
  # This class aggregates data from BGG, BGO, B2GO, Snakes & Lattes, etc.
  #
  # @example Creating a game
  #   game = Game.new(name: "Catan", rating: 8.0, weight: 2.5)
  #   game.rating #=> 8.0
  #   game.coop?  #=> false (checks coop_rank > 0)
  #
  class Game
    # Maximum weight threshold for displayable games (considered "light" games)
    MAX_DISPLAYABLE_WEIGHT = 2.2

    # Data files containing game lists (loaded once at startup)
    LEARNED_GAMES_FILE = "./data/learned.txt"
    REPLAYED_GAMES_FILE = "./data/replayed.txt"
    PLAYED_GAMES_FILE = "./data/played_games.txt"

    LEARNED = File.read(LEARNED_GAMES_FILE).split("\n").reject(&:blank?)
    REPLAYED = File.read(REPLAYED_GAMES_FILE).split("\n").reject(&:blank?)
    PLAYED = File.read(PLAYED_GAMES_FILE).split("\n").reject(&:blank?)

    # All known attributes that can be set on a Game.
    # These generate accessor methods via define_method.
    #
    # Core attributes:
    #   - name: String, the game's display name
    #   - rating: Float, BGG rating (0.0-10.0)
    #   - weight: Float, BGG complexity weight (1.0-5.0)
    #   - year: Integer, publication year
    #   - playtime: Integer, average playtime in minutes
    #
    # Player count:
    #   - min_player_count: Integer, minimum players
    #   - max_player_count: Integer, maximum players
    #
    # Pricing:
    #   - price: Float, general price
    #   - bgb_price: Float, Board Game Bliss price
    #
    # Source flags:
    #   - bgb: Boolean, available at Board Game Bliss
    #   - b2go: Boolean, available at B2GO
    #   - preorder: Boolean, is a preorder item
    #   - snakes: Boolean, available at Snakes & Lattes
    #
    # Category ranks (positive = belongs to category):
    #   - coop_rank, party_rank, strategy_rank, family_rank, etc.
    #
    KNOWN_ATTRIBUTES = %i[
      name
      rating
      weight
      year
      playtime
      rating_count
      min_player_count
      max_player_count
      price
      bgb_price
      offer_count
      bgb
      b2go
      preorder
      snakes
      snakes_location
      play_rank
      group
      coop_rank
      party_rank
      strategy_rank
      family_rank
      thematic_rank
      wargame_rank
      abstracts_rank
      children_rank
      customizable_rank
      kickstarter_rank
      gamefound_rank
      backerkit_rank
      campaign_rank
      child_rank
      banned_rank
      ccc_rank
      one_player_game_1_rank
      one_player_game_2_rank
    ].freeze

    # Category prefixes used for dynamic category checking.
    # Each generates a `prefix?` method that checks `prefix_rank > 0`.
    CATEGORY_PREFIXES = %i[
      coop
      party
      strategy
      family
      thematic
      wargame
      abstracts
      children
      customizable
      kickstarter
      gamefound
      backerkit
      campaign
      child
      banned
      ccc
      one_player_game_1
      one_player_game_2
    ].freeze

    attr_reader :attributes

    # Define explicit accessor methods for all known attributes
    KNOWN_ATTRIBUTES.each do |attr|
      define_method(attr) { attributes[attr] }
      define_method(:"#{attr}=") { |value| attributes[attr] = value }
    end

    # Define predicate methods for category ranks
    # A category is considered "active" if its rank is positive
    CATEGORY_PREFIXES.each do |prefix|
      define_method(:"#{prefix}?") do
        rank_value = attributes[:"#{prefix}_rank"]
        !null?(rank_value)
      end
    end

    # Creates a new Game with the given attributes.
    #
    # @param args [Hash] attribute values (see KNOWN_ATTRIBUTES)
    # @example
    #   Game.new(name: "Catan", rating: 8.0, weight: 2.5)
    #
    def initialize(args)
      @attributes = Hash.new(0).merge(args)
    end

    # Support for respond_to? on dynamic methods
    def respond_to_missing?(method_name, include_private = false)
      attr_name = method_name.to_s.chomp("=").chomp("?").to_sym
      KNOWN_ATTRIBUTES.include?(attr_name) ||
        CATEGORY_PREFIXES.include?(attr_name) ||
        super
    end

    # --------------------
    # Category Methods
    # --------------------

    # Returns a comma-separated label of all active categories and sources.
    #
    # @return [String] e.g., "coop, party, bgb, snakes"
    #
    def category_label
      @category_label ||= [*categories, *source_labels].compact.sort.join(", ")
    end

    # Returns array of active category prefixes.
    #
    # @return [Array<Symbol>] e.g., [:coop, :party]
    #
    def categories
      @categories ||= Config::Downloaders::CATEGORIES.map(&:prefix).select { send(:"#{it}?") }
    end

    # Returns comma-separated string of active subdomains.
    #
    # @return [String] e.g., "strategy, family"
    #
    def subdomains
      @subdomains ||= Config::Downloaders::SUBDOMAINS.map(&:prefix).select { send(:"#{it}?") }.join(", ")
    end

    # --------------------
    # Merge & Identity
    # --------------------

    # Merges this game with another, preferring non-null values from this game.
    #
    # @param other [Game] the game to merge with
    # @return [Game] a new merged game
    #
    def merge(other)
      Models::Game.new(attributes.merge(other.attributes) { |_, a, b| null?(a) ? b : a })
    end

    # Returns a normalized key for deduplication (lowercase, no punctuation).
    #
    # @return [String] e.g., "catan" for "Catan!"
    #
    def key
      @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
    end

    # --------------------
    # Game Data Methods
    # --------------------

    # Whether the game is available at Board Game Bliss (and not a preorder).
    def bgb?
      bgb == true && !preorder?
    end

    # Whether the game is competitive (not coop, party, or limited players).
    def competitive?
      group == "competitive"
    end

    # Whether the game was crowdfunded via any platform.
    def crowdfunded?
      kickstarter? || gamefound? || backerkit?
    end

    # Whether the user has learned this game.
    def learned?
      LEARNED.include?(name)
    end

    # Returns the normalized price, preferring BGBprice over general price.
    #
    # @return [Integer] price in dollars, rounded
    #
    def normalized_price
      (bgb_price > 0 ? bgb_price : price).to_f.round
    end

    # Whether the game is solo-only.
    def one_player?
      max_player_count == 1
    end

    # Whether the game has a play rank set.
    def play_rank?
      play_rank > 0
    end

    # Whether the user has played this game.
    def played?
      PLAYED.include?(name)
    end

    # Returns player count as a range string.
    #
    # @return [String] e.g., "2-4" or "1"
    #
    def player_count
      [min_player_count, max_player_count].compact.uniq.join("-")
    end

    # Returns player count as a Range object.
    #
    # @return [Range] e.g., 2..4
    #
    def player_count_range
      (min_player_count..max_player_count)
    end

    # Whether this is a preorder item.
    def preorder?
      preorder == true
    end

    # Whether the user has replayed this game.
    def replayed?
      REPLAYED.include?(name)
    end

    # Whether available at Snakes & Lattes.
    def snakes?
      snakes == true
    end

    # Returns snakes location as integer category.
    def snakes_category
      snakes_location.to_i
    end

    # Returns snakes location label, or nil if not set.
    def snakes_location_label
      null?(snakes_location) ? nil : snakes_location
    end

    # Whether the game can be played solo (solo-only OR coop starting at 1).
    def soloable?
      max_player_count == 1 || (coop? && min_player_count == 1)
    end

    # Whether the game is 2-player only.
    def two_player?
      max_player_count == 2
    end

    # Calculates average votes received per year since publication.
    #
    # @return [Integer] votes per year, rounded
    # @example
    #   game = Game.new(rating_count: 1000, year: 2023)
    #   game.votes_per_year #=> ~500 (depending on current date)
    #
    def votes_per_year
      days_published = ((Time.now.year - year.to_i) * 365) + Time.now.yday
      years_published = days_published.to_f / 365

      (rating_count / years_published).round
    end

    # Returns the game's group classification.
    #
    # @return [String] one of: "party", "coop", "1-player", "2-player", "competitive"
    #
    def group
      case
      when party? then "party"
      when coop? then "coop"
      when one_player? then "1-player"
      when two_player? then "2-player"
      else "competitive"
      end
    end

    # Returns minimum player count, with special handling for solo variants.
    #
    # Games with one_player_game_1 or one_player_game_2 flags
    # are considered to have a minimum of 1 player.
    #
    # @return [Integer] minimum number of players
    #
    def min_player_count
      return 1 if one_player_game_1?
      return 1 if one_player_game_2?

      attributes[:min_player_count]
    end

    # --------------------
    # Customization Methods
    # --------------------

    # Whether available at B2GO (includes manual overrides).
    def b2go?
      b2go == true || Config::GameLists.b2go_overrides.include?(name)
    end

    # Whether this game is banned from display.
    # Checks individual ban, series ban, and category bans.
    def banned?
      banned_game? || banned_series? || Config::GameLists.banned_categories.any? { send("#{it}?") }
    end

    # Whether this specific game is banned.
    def banned_game?
      Config::GameLists.banned_games.include?(name)
    end

    # Whether this game belongs to a banned series.
    def banned_series?
      Config::GameLists.banned_series.any? { name.start_with?(it) }
    end

    # Whether this is a CCC game (includes manual overrides).
    def ccc?
      ccc_rank_active? || Config::GameLists.ccc_overrides.include?(name)
    end

    # Whether this is a children's game (includes manual overrides).
    def child?
      child_rank_active? || Config::GameLists.child_overrides.include?(name)
    end

    # Whether to always keep this game in results.
    def keep?
      Config::GameLists.keep.include?(name)
    end

    # Whether this is a skirmish game.
    def skirmish?
      Config::GameLists.skirmish_games.include?(name)
    end

    # Returns the game's weight, with manual overrides.
    #
    # @return [Float] complexity weight (1.0-5.0)
    #
    def weight
      Config::GameLists.weight_overrides.fetch(name, attributes[:weight])
    end

    # --------------------
    # Display Logic
    # --------------------

    # Determines if this game should be displayed in results.
    #
    # Display rules (in order of priority):
    # 1. EXCLUDE if weight > MAX_DISPLAYABLE_WEIGHT (too complex)
    # 2. EXCLUDE if already played
    # 3. EXCLUDE if not from a tracked source (b2go, snakes, or learned)
    # 4. INCLUDE if learned (user explicitly added)
    # 5. INCLUDE if on keep list
    # 6. EXCLUDE if it's a campaign game
    # 7. EXCLUDE if banned
    # 8. EXCLUDE if not soloable (min_player_count != 1)
    # 9. INCLUDE otherwise
    #
    # @return [Boolean] whether to display this game
    #
    def displayable?
      return false if weight.round(1) > MAX_DISPLAYABLE_WEIGHT
      return false if played?
      return false unless b2go? || snakes? || learned?
      return true if learned?
      return true if keep?
      return false if campaign?
      return false if banned?
      return false unless min_player_count == 1

      true
    end

    private

    # Helper methods for customization that need to avoid recursion
    def ccc_rank_active?
      !null?(attributes[:ccc_rank])
    end

    def child_rank_active?
      !null?(attributes[:child_rank])
    end

    # Returns source labels for active sources.
    #
    # @return [Array<Symbol>] e.g., [:bgb, :snakes]
    #
    def source_labels
      [
        (:b2go if b2go?),
        (:bgb if bgb?),
        (:ccc if ccc?),
        (:preorder if preorder?),
        (:snakes if snakes?),
      ]
    end

    # Checks if a value is "null" (nil, zero, or falsy).
    #
    # @param value [Object] the value to check
    # @return [Boolean] true if null/zero/nil
    #
    def null?(value)
      !value || (value.respond_to?(:zero?) && value.zero?)
    end
  end
end
```

---

### `lib/parsers/bgo_game.rb` (Rewritten)

```ruby
# frozen_string_literal: true

module Parsers
  # Parses game data from BGO (Board Game Oracle) format.
  #
  # BGO data comes in three formats depending on available information:
  #
  # Format A (5 parts) - Basic game info:
  #   Line 1: Game name
  #   Line 2: Player count (e.g., "2-4")
  #   Line 3: Playtime in minutes
  #   Line 4: Rating (e.g., "7.5")
  #   Line 5: Weight/complexity (e.g., "2.3")
  #
  # Format B (6 parts) - With year and offer count:
  #   Line 1: Game name
  #   Line 2: Year • Offer count (e.g., "2020•5")
  #   Line 3: Player count
  #   Line 4: Playtime
  #   Line 5: Rating
  #   Line 6: Weight
  #
  # Format C (9 parts) - Full listing with price:
  #   Line 1: Game name
  #   Line 2: Year • Offer count
  #   Line 3: Unknown field (ignored)
  #   Line 4: Unknown field (ignored)
  #   Line 5: Price (e.g., "$49.99")
  #   Line 6: Player count
  #   Line 7: Playtime
  #   Line 8: Rating
  #   Line 9: Weight
  #
  # @example Parsing BGO data
  #   data = "Catan\n2020•5\n3-4\n60\n7.5\n2.3"
  #   parser = BgoGame.new(data)
  #   game = parser.to_game
  #
  class BgoGame
    include Concerns::Parseable
    include Concerns::PlayerCountParser

    # Expected part counts for each data format
    FORMAT_BASIC = 5
    FORMAT_WITH_YEAR = 6
    FORMAT_FULL = 9

    # Separator between year and offer count in format B and C
    YEAR_OFFER_SEPARATOR = "•"

    attr_reader :name,
                :rating,
                :weight,
                :year,
                :offer_count,
                :min_player_count,
                :max_player_count,
                :price,
                :playtime

    # Parses raw BGO data string into structured attributes.
    #
    # @param data [String] newline-separated BGO data
    # @raise [ArgumentError] if data format is not recognized
    #
    def initialize(data)
      parts = data.split("\n")

      case parts.size
      when FORMAT_BASIC
        parse_basic_format(parts)
      when FORMAT_WITH_YEAR
        parse_with_year_format(parts)
      when FORMAT_FULL
        parse_full_format(parts)
      else
        raise ArgumentError, "Unexpected BGO data format: expected #{FORMAT_BASIC}, #{FORMAT_WITH_YEAR}, or #{FORMAT_FULL} parts, got #{parts.size}"
      end
    end

    # Converts parsed data to a Game model.
    #
    # @return [Models::Game, nil] the game, or nil if name is blank
    #
    def to_game
      return if name.blank?

      Models::Game.new(
        name: name,
        rating: rating,
        weight: weight,
        year: year,
        offer_count: offer_count,
        min_player_count: min_player_count,
        max_player_count: max_player_count,
        price: price,
        playtime: playtime
      )
    end

    private

    # Parses Format A: basic game info (5 parts)
    def parse_basic_format(parts)
      @name, player_count, playtime_str, rating_str, weight_str = parts

      @year = nil
      @offer_count = nil
      @price = nil
      @playtime = playtime_str.to_i
      @rating = rating_str.to_f
      @weight = weight_str.to_f
      @min_player_count, @max_player_count = parse_player_count(player_count)
    end

    # Parses Format B: with year and offer count (6 parts)
    def parse_with_year_format(parts)
      @name, year_offer_str, player_count, playtime_str, rating_str, weight_str = parts

      @year, @offer_count = parse_year_and_offer_count(year_offer_str)
      @price = nil
      @playtime = playtime_str.to_i
      @rating = rating_str.to_f
      @weight = weight_str.to_f
      @min_player_count, @max_player_count = parse_player_count(player_count)
    end

    # Parses Format C: full listing with price (9 parts)
    def parse_full_format(parts)
      @name, year_offer_str, _unknown1, _unknown2, price_str, player_count, playtime_str, rating_str, weight_str = parts

      @year, @offer_count = parse_year_and_offer_count(year_offer_str)
      @price = parse_price(price_str)
      @playtime = playtime_str.to_i
      @rating = rating_str.to_f
      @weight = weight_str.to_f
      @min_player_count, @max_player_count = parse_player_count(player_count)
    end

    # Parses year and offer count from combined string.
    #
    # @param str [String, nil] e.g., "2020•5"
    # @return [Array<Integer, Integer>] [year, offer_count] or [nil, nil]
    #
    def parse_year_and_offer_count(str)
      return [nil, nil] if str.nil?

      str.split(YEAR_OFFER_SEPARATOR).map(&:to_i)
    end

    # Parses price string to float.
    #
    # @param str [String, nil] e.g., "$49.99"
    # @return [Float, nil] the price or nil
    #
    def parse_price(str)
      return nil if str.nil?

      str.delete_prefix("$").to_f
    end
  end
end
```

---

### `lib/parsers/bgb_game.rb` (Rewritten)

```ruby
# frozen_string_literal: true

module Parsers
  # Parses game data from BGB (Board Game Bliss) format.
  #
  # BGB data format (10 lines, newline-separated):
  #   Line 0: Unknown (ignored)
  #   Line 1: Unknown (ignored)
  #   Line 2: Game name
  #   Line 3: Unknown (ignored)
  #   Line 4: Player count (e.g., "2-4")
  #   Line 5: Playtime in minutes (e.g., "60")
  #   Line 6: Rating (e.g., "7.5")
  #   Line 7: Weight/complexity (e.g., "2.3")
  #   Line 8: Preorder indicator (contains "*PRE-ORDER*" if preorder)
  #   Line 9: Price (e.g., "$49.99")
  #
  # @example Parsing BGB data
  #   data = "...\n...\nCatan\n...\n2-4\n60\n7.5\n2.3\n\n$49.99"
  #   parser = BgbGame.new(data)
  #   game = parser.to_game
  #
  class BgbGame
    include Concerns::Parseable
    include Concerns::PlayerCountParser

    # Line indices for BGB data format
    LINE_NAME = 2
    LINE_PLAYER_COUNT = 4
    LINE_PLAYTIME = 5
    LINE_RATING = 6
    LINE_WEIGHT = 7
    LINE_PREORDER = 8
    LINE_PRICE = 9

    # String indicating a preorder item
    PREORDER_INDICATOR = "*PRE-ORDER*"

    attr_reader :name,
                :min_player_count,
                :max_player_count,
                :playtime,
                :rating,
                :weight,
                :preorder,
                :price

    # Parses raw BGB data string into structured attributes.
    #
    # @param data [String] newline-separated BGB data (10 lines expected)
    #
    def initialize(data)
      lines = data.split("\n")

      @name = lines[LINE_NAME]
      @playtime = lines[LINE_PLAYTIME].to_i
      @rating = lines[LINE_RATING].to_f
      @weight = lines[LINE_WEIGHT].to_f
      @preorder = lines[LINE_PREORDER].to_s.include?(PREORDER_INDICATOR)
      @price = parse_price(lines[LINE_PRICE])
      @min_player_count, @max_player_count = parse_player_count(lines[LINE_PLAYER_COUNT])
    end

    # Converts parsed data to a Game model.
    #
    # @return [Models::Game, nil] the game, or nil if name is blank
    #
    def to_game
      return if name.blank?

      Models::Game.new(
        name: name,
        rating: rating,
        weight: weight,
        preorder: preorder,
        bgb: true,
        min_player_count: min_player_count,
        max_player_count: max_player_count,
        bgb_price: price,
        playtime: playtime
      )
    end

    private

    # Parses price string to float.
    #
    # @param str [String, nil] e.g., "$49.99"
    # @return [Float] the price
    #
    def parse_price(str)
      str.to_s.delete_prefix("$").to_f
    end
  end
end
```

---

### `lib/parsers/concerns/parseable.rb` (Rewritten)

```ruby
# frozen_string_literal: true

module Parsers
  module Concerns
    # Provides a standard `parse` class method for all parsers.
    #
    # When included in a parser class, adds a `parse` class method that:
    # 1. Creates a new instance with the given data
    # 2. Calls `to_game` to convert to a Game model
    # 3. Returns nil if any parsing error occurs
    #
    # @example Using Parseable
    #   class BgbGame
    #     include Concerns::Parseable
    #
    #     def initialize(data)
    #       # parse data
    #     end
    #
    #     def to_game
    #       # return Models::Game
    #     end
    #   end
    #
    #   game = BgbGame.parse(raw_data)  # Uses the class method
    #
    module Parseable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Parses raw data and returns a Game model.
        #
        # This is a safe wrapper that catches parsing errors and returns nil
        # instead of raising. This allows batch processing to continue even
        # if individual records are malformed.
        #
        # Known error conditions that may return nil:
        # - ArgumentError: unexpected data format
        # - NoMethodError: missing expected fields
        # - TypeError: nil values where not expected
        #
        # @param data [String] raw data string to parse
        # @return [Models::Game, nil] the parsed game, or nil on error
        #
        def parse(data)
          new(data).to_game
        rescue ArgumentError, NoMethodError, TypeError => e
          # Log error in development for debugging
          Rails.logger.debug { "Parse error for #{name}: #{e.message}" } if defined?(Rails)
          nil
        rescue StandardError => e
          # Catch-all for unexpected errors
          Rails.logger.warn { "Unexpected parse error for #{name}: #{e.class} - #{e.message}" } if defined?(Rails)
          nil
        end
      end
    end
  end
end
```

---

## Summary of Improvements

| Issue | Before | After |
|-------|--------|-------|
| `method_missing` discoverability | No `respond_to_missing?`, no attribute list | `KNOWN_ATTRIBUTES` constant + `respond_to_missing?` |
| Magic numbers | `2.2` hardcoded | `MAX_DISPLAYABLE_WEIGHT = 2.2` |
| `concerning` blocks | Fragmented class | Single cohesive class with section comments |
| Parser magic indices | `_, _, @name, _, player_count...` | Named constants: `LINE_NAME = 2`, etc. |
| Data format documentation | None | Full format documentation in class comments |
| Error handling | Silent `rescue StandardError` | Documented specific exceptions with logging |
| Method documentation | None | YARD-style comments on all public methods |
| Business logic clarity | Unclear rules | Documented decision tree in `displayable?` |

These changes make the code significantly more comprehensible to AI assistants while maintaining identical functionality.
