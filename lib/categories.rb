require_relative "bgg_games"

module Categories
  MECHANICS = [
    ["action_points", 2001],
    ["campaign", 2822],
    ["card_driven", 2018],
    ["coop", 2023],
    ["dice", 2072],
    ["flicking", 2860],
    ["legacy", 2824],
    ["narrative_choice", 2851],
    ["realtime", 2831],
    ["solo", 2819],
    ["stacking", 2988],
    ["storytelling", 2027],
  ].map { |prefix, listid| BggGames.new(prefix:, listid:, page_count: 20, object_type: "property") }

  FAMILIES = [
    ["app", 41489],
    ["bga", 70360],
    ["kickstarter", 8374],
  ].map { |prefix, listid| BggGames.new(prefix:, listid:, page_count: 20, object_type: "family") }

  CATEGORIES = MECHANICS.map(&:prefix) + FAMILIES.map(&:prefix)
  RANK_FIELDS = CATEGORIES
end
