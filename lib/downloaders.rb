require_relative "downloaders/category_games"
require_relative "downloaders/game_search"
require_relative "downloaders/top_played"
require_relative "downloaders/geek_list"


module Downloaders
  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"
  MECHANICS = Categories::MECHANICS.map do |prefix, listid, items_per_page|
    CategoryGames.new(prefix: prefix, listid: listid, items_per_page: items_per_page, object_type: "property")
  end
  # PLAYER_COUNTS = (1..12).map do |count|
  PLAYER_COUNTS = (1..2).map do |count|
    GameSearch.new(prefix: :"player_#{count}", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=#{count}&range[maxplayers][min]=#{count}&playerrangetype=normal")
  end
  # PLAYTIMES = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240, 300, 360].map do |playtime|
  PLAYTIMES = [15, 30, 45, 60, 90].map do |playtime|
    GameSearch.new(prefix: :"playtime_#{playtime}", listid: "playtime", search_criteria: "#{SORTBY_RANK}&range[playtime][max]=#{playtime}")
  end
  DOWNLOADERS = [
    TopPlayed.new(prefix: :play, listid: "plays"),
    GameSearch.new(prefix: :bgg, listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: :vote, listid: "numvoters", search_criteria: SORTBY_VOTES),
    GeekList.new(prefix: "corridor", listid: 342128, reverse_rank: false),
    GeekList.new(prefix: "couples", listid: 328691, reverse_rank: false),
    GeekList.new(prefix: "solo", listid: 324731, reverse_rank: false),
    *PLAYER_COUNTS,
    *PLAYTIMES,
    *MECHANICS,
  ]
end
