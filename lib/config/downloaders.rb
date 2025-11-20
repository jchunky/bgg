require_relative "../downloaders/b2go_data"
require_relative "../downloaders/bgb_data"
require_relative "../downloaders/bgo_data"
require_relative "../downloaders/category_games"
require_relative "../downloaders/game_search"
require_relative "../downloaders/geek_list"
require_relative "../downloaders/snakes_data"
require_relative "../downloaders/top_played_data"

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
  DOWNLOADERS = [
    GameSearch.new(prefix: :bgg, listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: :vote, listid: "numvoters", search_criteria: SORTBY_VOTES),
    GeekList.new(prefix: :couples, listid: 353032, reverse_rank: false), # 2024
    GeekList.new(prefix: :solo, listid: 366471, reverse_rank: true), # 2025
    BgoData.new,
    BgbData.new,
    B2goData.new,
    SnakesData.new,
    TopPlayedData.new,
    *CATEGORIES,
    *SUBDOMAINS,
  ]
end
