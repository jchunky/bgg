require_relative "game_search"
require_relative "top_played"

module Downloaders
  include Categories

  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"

  DOWNLOADERS = [
    TopPlayed.new,

    GameSearch.new(prefix: "bgg", search_criteria: SORTBY_RANK, listid: "rank"),
    GameSearch.new(prefix: "vote", search_criteria: SORTBY_VOTES, listid: "numvoters"),

    *MECHANICS,
    *FAMILIES,
  ]
end
