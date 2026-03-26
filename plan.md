# Plan: Remove Legacy B2GO Parser + Extract Value Objects

## Tasks

1. ~~Remove legacy `Parsers::B2goGame` and its specs~~ (0aef8e3)
2. ~~Extract `PlayerCount` value object~~ (e1c1174)
3. ~~Extract `Weight` value object~~ (a444b09)

## Additional Commits

4. ~~Remove `displayable?` from Weight~~ (ba37772)
5. ~~Extract `NormalizedName` value object~~ (9289860)

## Improvement Opportunities

- Game model is now 140 lines (target: 100). Remaining candidates:
  `votes_per_year` computation, `group` classification, or the
  `Customize` concern could move to a service/policy object.
