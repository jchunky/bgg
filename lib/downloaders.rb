require_relative "downloaders/category_games"
require_relative "downloaders/game_search"
require_relative "downloaders/top_played"

module Downloaders
  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"
  MECHANICS = Categories::MECHANICS.map { |prefix, listid| CategoryGames.new(prefix:, listid:, object_type: "property") }
  FAMILIES = Categories::FAMILIES.map { |prefix, listid| CategoryGames.new(prefix:, listid:, object_type: "family") }
  SUBDOMAINS = Categories::SUBDOMAINS.map do |prefix, listid|
    GameSearch.new(prefix:, listid:, search_criteria: "#{SORTBY_RANK}&familyids[]=#{listid}")
  end
  PLAYER_COUNTS = (1..12).map do |count|
    GameSearch.new(prefix: "player_#{count}", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=#{count}&range[maxplayers][min]=#{count}&playerrangetype=normal")
  end

  DOWNLOADERS = [
    TopPlayed.new(prefix: "play", listid: "plays"),
    GameSearch.new(prefix: "bgg", listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: "vote", listid: "numvoters", search_criteria: SORTBY_VOTES),
    *MECHANICS,
    *FAMILIES,
    *SUBDOMAINS,
    *PLAYER_COUNTS,
  ]
end
