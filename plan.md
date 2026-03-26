# Plan: Remove Legacy B2GO Parser + Extract Value Objects

## Tasks

1. ~~Remove legacy `Parsers::B2goGame` and its specs~~ (0aef8e3)
2. ~~Extract `PlayerCount` value object~~ (e1c1174)
3. ~~Extract `Weight` value object~~ (a444b09)

## Improvement Opportunities

- Game model is still 154 lines (target: 100). The `key` method
  (17 lines of chained gsubs) is a candidate for its own value
  object (`GameKey` or `NormalizedName`).
- The `Customize` concern's `weight` method now memoizes a
  `Weight` object but still does override resolution itself.
  Could move override logic into a factory method on Weight.
- Template still has inline `!(1...3).cover?(game.weight&.round(1))`
  — could use `weight.displayable?` or a similar predicate for the
  "bad weight" highlight (the threshold differs: 2.2 vs 3.0).
