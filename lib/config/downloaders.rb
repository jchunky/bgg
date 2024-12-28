require_relative "../downloaders/bgo_data"
require_relative "../downloaders/category_games"
require_relative "../downloaders/game_search"
require_relative "../downloaders/geek_list"
require_relative "../downloaders/top_played"

module Downloaders
  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"
  CATEGORIES = Categories::CATEGORIES.map do |prefix, listid, items_per_page, object_type|
    CategoryGames.new(prefix:, listid:, items_per_page:, object_type:)
  end
  SUBDOMAINS = Categories::SUBDOMAINS.map do |prefix, listid, items_per_page|
    CategoryGames.new(prefix:, listid:, items_per_page:, object_type: "family")
  end
  # PLAYER_COUNTS = (1..12).map do |count|
  PLAYER_COUNTS = (1..2).map do |count|
    GameSearch.new(prefix: :"player_#{count}", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=#{count}&range[maxplayers][min]=#{count}&playerrangetype=normal")
  end
  # PLAYTIMES = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240, 300, 360].map do |playtime|
  PLAYTIMES = [60].map do |playtime|
    GameSearch.new(prefix: :"playtime_#{playtime}", listid: "playtime", search_criteria: "#{SORTBY_RANK}&range[playtime][max]=#{playtime}")
  end
  DOWNLOADERS = [
    TopPlayed.new(prefix: :play, listid: "plays"),
    GameSearch.new(prefix: :bgg, listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: :vote, listid: "numvoters", search_criteria: SORTBY_VOTES),
    GeekList.new(prefix: "corridor", listid: 347808, reverse_rank: false), # November 2024
    GeekList.new(prefix: "couples", listid: 328691, reverse_rank: false), # 2023
    GeekList.new(prefix: "solo", listid: 345687, reverse_rank: false), # 2024
    *PLAYER_COUNTS,
    *PLAYTIMES,
    *CATEGORIES,
    *SUBDOMAINS,
  ]
end
