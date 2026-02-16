# AI-Friendly Ruby Code Guidelines

Guidelines for writing Ruby code that AI assistants (like Claude, GitHub Copilot, etc.) can understand, navigate, and modify effectively.

## Core Principles

1. **Explicitness over Magic** - AI can't run code, so it needs to statically understand what exists
2. **Discoverability** - AI should be able to find all methods/attributes by reading the code
3. **Predictability** - Consistent patterns help AI recognize intent
4. **Single Source of Truth** - One place to look for definitions

---

## Code Structure & Organization

### Favor Explicit Method Definitions

```ruby
# ❌ Avoid: method_missing (AI can't know what methods exist)
def method_missing(method_name, *args)
  attributes[method_name]
end

# ✅ Prefer: define_method with explicit list
ATTRIBUTES = %i[name rating weight rank]

ATTRIBUTES.each do |attr|
  define_method(attr) { attributes[attr] }
  define_method(:"#{attr}=") { |val| attributes[attr] = val }
end
```

### Favor Struct over OpenStruct

```ruby
# ❌ Avoid: OpenStruct (any attribute accepted, no discoverability)
game = OpenStruct.new(name: "Catan", rating: 8.0)
game.typo_attribute = "oops"  # Silent success

# ✅ Prefer: Struct (explicit attributes, raises on typos)
Game = Struct.new(:name, :rating, :weight, keyword_init: true)
game = Game.new(name: "Catan", rating: 8.0)
```

### One Class Per File

```ruby
# ❌ Avoid: Multiple classes in one file
# lib/models.rb
class Game; end
class Player; end
class Score; end

# ✅ Prefer: One class per file matching path
# lib/models/game.rb
class Game; end
```

### Keep Methods Short

```ruby
# ❌ Avoid: Long methods (>15 lines)
def process_game
  # 50 lines of code...
end

# ✅ Prefer: Small, focused methods
def process_game
  validate_game
  calculate_score
  save_result
end
```

---

## Metaprogramming Guidelines

### Avoid Runtime Code Generation

```ruby
# ❌ Avoid
eval("def #{name}; @#{name}; end")
instance_eval { define_method(:foo) { "bar" } }
Object.const_get(class_name).new

# ✅ Prefer
attr_reader :name
def foo; "bar"; end
Game.new
```

### If You Must Use method_missing, Add respond_to_missing?

```ruby
# ⚠️ Acceptable: method_missing WITH respond_to_missing?
def method_missing(method_name, *args)
  return attributes[method_name] if attributes.key?(method_name)
  super
end

def respond_to_missing?(method_name, include_private = false)
  attributes.key?(method_name) || super
end
```

### Document Dynamic Methods

```ruby
# When using metaprogramming, add a constant for discoverability
ATTRIBUTES = %i[name rating weight rank year playtime]
# AI can now search for ATTRIBUTES to understand the interface

ATTRIBUTES.each do |attr|
  define_method(attr) { @data[attr] }
end
```

---

## Naming & Conventions

### Use Descriptive Names

```ruby
# ❌ Avoid
def calc_vpy
  rc / yrs_pub
end

# ✅ Prefer
def votes_per_year
  rating_count / years_published
end
```

### Constants for Magic Values

```ruby
# ❌ Avoid
return false if weight > 2.2

# ✅ Prefer
MAX_WEIGHT_THRESHOLD = 2.2
return false if weight > MAX_WEIGHT_THRESHOLD
```

### Consistent Naming Patterns

```ruby
# ✅ Good: Consistent suffixes
coop_rank
party_rank
strategy_rank

# ✅ Good: Consistent predicates
def coop?; coop_rank.positive?; end
def party?; party_rank.positive?; end
```

---

## Dependencies & Configuration

### Explicit Requires

```ruby
# ❌ Avoid: Relying on autoloading without indication
# (AI doesn't know what's available)

# ✅ Prefer: Explicit requires or documented autoloading
require_relative "models/game"
# OR: Document autoloader at top of file
# Uses Zeitwerk autoloading - see lib/loader.rb
```

### Constants Over External Config

```ruby
# ❌ Avoid: Hidden in YAML/ENV (AI can't see values)
MAX_PLAYERS = YAML.load_file("config.yml")["max_players"]

# ✅ Prefer: Visible in code
MAX_PLAYERS = 6
```

### Document External APIs Inline

```ruby
# ✅ Good: AI can understand without fetching docs
# BGG API: https://boardgamegeek.com/wiki/page/BGG_XML_API2
# Returns: { "items" => [{ "name" => "...", "rank" => ... }] }
def fetch_games
  response = get("/api/games")
  response["items"]
end
```

---

## Ruby-Specific Patterns

### Direct Calls Over send()

```ruby
# ❌ Avoid: AI can't trace call graph
object.send(method_name, *args)

# ✅ Prefer: Direct calls when possible
object.process_game
```

### Explicit Blocks Over Symbol Procs

```ruby
# ⚠️ Acceptable but less clear
games.map(&:name)

# ✅ More explicit for complex operations
games.map { |game| game.name.downcase.strip }
```

### Module Mixins Over Runtime Extensions

```ruby
# ❌ Avoid
game.extend(SomeModule)
game.define_singleton_method(:foo) { "bar" }

# ✅ Prefer
class Game
  include SomeModule
end
```

---

## Testing & Documentation

### Comprehensive Tests

Tests serve as executable documentation for AI:

```ruby
# ✅ AI uses tests to understand behavior
RSpec.describe Game do
  describe "#votes_per_year" do
    it "calculates votes based on rating_count and year" do
      game = Game.new(rating_count: 1000, year: 2023)
      expect(game.votes_per_year).to be_within(50).of(500)
    end
  end
end
```

### Mirror Test Structure to Lib Structure

```
lib/
  models/
    game.rb
  parsers/
    bgb_game.rb
spec/
  models/
    game_spec.rb       # Mirrors lib/models/game.rb
  parsers/
    bgb_game_spec.rb   # Mirrors lib/parsers/bgb_game.rb
```

### RDoc/YARD Comments on Public Methods

```ruby
# Calculates the average votes received per year since publication.
#
# @return [Integer] votes per year, rounded
# @example
#   game.votes_per_year #=> 500
def votes_per_year
  (rating_count / years_published).round
end
```

### Consider Type Annotations (RBS/Sorbet)

```ruby
# sig/models/game.rbs
class Models::Game
  attr_reader name: String
  attr_reader rating: Float
  attr_reader weight: Float
  
  def votes_per_year: () -> Integer
end
```

---

## Summary Checklist

- [ ] No `method_missing` without `respond_to_missing?`
- [ ] Explicit attribute lists (constants)
- [ ] One class per file
- [ ] Methods under 15 lines
- [ ] Descriptive names (no abbreviations)
- [ ] Constants for magic values
- [ ] Explicit requires or documented autoloading
- [ ] Comprehensive test coverage
- [ ] Test structure mirrors lib structure
- [ ] Comments on complex public methods
- [ ] Avoid `eval`, `send`, `const_get` when possible

---

## References

- [Ruby Style Guide](https://rubystyle.guide/)
- [RBS Documentation](https://github.com/ruby/rbs)
- [Sorbet](https://sorbet.org/)
- [YARD Documentation](https://yardoc.org/)
