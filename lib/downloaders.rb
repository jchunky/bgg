require_relative "downloaders/category_games"
require_relative "downloaders/game_search"
require_relative "downloaders/top_played"

module Downloaders
  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"

  DOWNLOADERS = [
    TopPlayed.new(prefix: "play", listid: "plays"),

    GameSearch.new(prefix: "bgg", listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: "vote", listid: "numvoters", search_criteria: SORTBY_VOTES),
    GameSearch.new(prefix: "solo", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=1&range[minplayers][max]=1"),

    *(Categories::MECHANICS.map { |prefix, listid| CategoryGames.new(prefix:, listid:, object_type: "property") }),
    *(Categories::FAMILIES.map { |prefix, listid| CategoryGames.new(prefix:, listid:, object_type: "family") }),
  ]
end
