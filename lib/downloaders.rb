require_relative "game_search"
require_relative "top_played"

module Downloaders
  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"

  DOWNLOADERS = [
    TopPlayed.new(prefix: "play", listid: "plays"),

    GameSearch.new(prefix: "bgg", listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: "vote", listid: "numvoters", search_criteria: SORTBY_VOTES),

    *(Categories::MECHANICS.map { |prefix, listid| BggGames.new(prefix:, listid:, page_count: 20, object_type: "property") }),
    *(Categories::FAMILIES.map { |prefix, listid| BggGames.new(prefix:, listid:, page_count: 20, object_type: "family") }),
  ]
end
