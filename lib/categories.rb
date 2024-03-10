require_relative "bgg_games"

module Categories
  MECHANICS = [
    BggGames.new(object_type: "property", prefix: "action_points", listid: 2001, page_count: 20),
    BggGames.new(object_type: "property", prefix: "campaign", listid: 2822, page_count: 20),
    BggGames.new(object_type: "property", prefix: "card_driven", listid: 2018, page_count: 20),
    BggGames.new(object_type: "property", prefix: "coop", listid: 2023, page_count: 20),
    BggGames.new(object_type: "property", prefix: "dice", listid: 2072, page_count: 20),
    BggGames.new(object_type: "property", prefix: "flicking", listid: 2860, page_count: 20),
    BggGames.new(object_type: "property", prefix: "legacy", listid: 2824, page_count: 20),
    BggGames.new(object_type: "property", prefix: "narrative_choice", listid: 2851, page_count: 20),
    BggGames.new(object_type: "property", prefix: "realtime", listid: 2831, page_count: 20),
    BggGames.new(object_type: "property", prefix: "solo", listid: 2819, page_count: 20),
    BggGames.new(object_type: "property", prefix: "stacking", listid: 2988, page_count: 20),
    BggGames.new(object_type: "property", prefix: "storytelling", listid: 2027, page_count: 20),
  ]

  FAMILIES = [
    BggGames.new(object_type: "family", prefix: "app", listid: 41489, page_count: 20),
    BggGames.new(object_type: "family", prefix: "bga", listid: 70360, page_count: 20),
    BggGames.new(object_type: "family", prefix: "kickstarter", listid: 8374, page_count: 20),
  ]

  CATEGORIES = MECHANICS.map(&:prefix) + FAMILIES.map(&:prefix)
  RANK_FIELDS = CATEGORIES
end
