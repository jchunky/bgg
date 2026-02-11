module Config
  module Downloaders
    NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
    SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
    SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"
    ONE_PLAYER_GAMES_1 = "#{SORTBY_RANK}&range[minplayers][max]=1&floatrange[avgweight][max]=2.5"
    ONE_PLAYER_GAMES_2 = "#{SORTBY_RANK}&range[minplayers][max]=1&floatrange[avgweight][min]=2.5"

    CATEGORIES = Config::Categories::CATEGORIES.map do |prefix, listid, items_per_page, object_type|
      ::Downloaders::CategoryGames.new(prefix:, listid:, items_per_page:, object_type:)
    end
    SUBDOMAINS = Config::Categories::SUBDOMAINS.map do |prefix, listid, items_per_page|
      ::Downloaders::CategoryGames.new(prefix:, listid:, items_per_page:, object_type: "family")
    end
    DOWNLOADERS = [
      ::Downloaders::GameSearch.new(prefix: :bgg, listid: "rank", search_criteria: SORTBY_RANK),
      ::Downloaders::GameSearch.new(prefix: :one_player_game_1, listid: "minplayers", search_criteria: ONE_PLAYER_GAMES_1),
      ::Downloaders::GameSearch.new(prefix: :one_player_game_2, listid: "minplayers", search_criteria: ONE_PLAYER_GAMES_2),
      # ::Downloaders::GameSearch.new(prefix: :vote, listid: "numvoters", search_criteria: SORTBY_VOTES),
      ::Downloaders::GeekList.new(prefix: :ccc, listid: 370740, reverse_rank: false), # December 2025
      ::Downloaders::GeekList.new(prefix: :couples, listid: 353032, reverse_rank: false), # 2024
      ::Downloaders::GeekList.new(prefix: :solo, listid: 366471, reverse_rank: false), # 2025

      ::Downloaders::BgoData.new,
      ::Downloaders::BgbData.new,
      ::Downloaders::B2goData.new,
      ::Downloaders::SnakesData.new,
      ::Downloaders::TopPlayedData.new,
      *CATEGORIES,
      *SUBDOMAINS,
    ]
  end
end
