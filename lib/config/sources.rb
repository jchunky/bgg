# frozen_string_literal: true

module Config
  module Sources
    NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
    SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank".freeze
    ONE_PLAYER_GAMES_1 = "#{SORTBY_RANK}&range[minplayers][max]=1&floatrange[avgweight][max]=2.5".freeze
    ONE_PLAYER_GAMES_2 = "#{SORTBY_RANK}&range[minplayers][max]=1&floatrange[avgweight][min]=2.5".freeze

    CATEGORIES = Config::Categories::CATEGORIES.map do |prefix, listid, items_per_page, object_type, display|
      ::Downloaders::CategoryGames.new(prefix:, listid:, items_per_page:, object_type:, display: display.nil? || display)
    end
    SUBDOMAINS = Config::Categories::SUBDOMAINS.map do |prefix, listid, items_per_page|
      ::Downloaders::CategoryGames.new(prefix:, listid:, items_per_page:, object_type: "family")
    end
    DOWNLOADERS = [
      ::Downloaders::BggSearch.new(prefix: :bgg, listid: "rank", search_criteria: SORTBY_RANK),
      ::Downloaders::BggSearch.new(prefix: :one_player_game_1, listid: "minplayers", search_criteria: ONE_PLAYER_GAMES_1),
      ::Downloaders::BggSearch.new(prefix: :one_player_game_2, listid: "minplayers", search_criteria: ONE_PLAYER_GAMES_2),
      ::Downloaders::B2goData.new,
      ::Downloaders::BgpData.new,
      *CATEGORIES,
      *SUBDOMAINS,
    ].freeze
  end
end
