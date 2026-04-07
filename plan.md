# Refactoring Plan: Push Data & Methods onto Classes

Goal: Apply "Tell, Don't Ask" and extract value objects across the codebase.

## Tasks

1. [x] **Extract `Classification` value object** from raw arrays in `Config::Classifications`
2. [x] **Push `valid_bgg_id?` onto `Game`**
3. [x] **Extract `StoreLinks` value object** from `bgp_store_links`
4. [x] **Push `banned?` logic into a `BanList` object**
5. [x] **Push `bad_value` knowledge onto `Game`** as `comparable_value_for`
6. [x] **Extract `PublicationAge` value object** from `votes_per_year`
7. [x] **Push `combine` onto `StoreLinks`** — addressed in task 3; remaining code is clean

## Improvement opportunities

_(none identified)_
