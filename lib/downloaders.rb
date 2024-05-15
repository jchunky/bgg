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
    GameSearch.new(prefix: "child", listid: "4665", search_criteria: "#{SORTBY_RANK}&familyids[]=4665"),
    GameSearch.new(prefix: "ccg", listid: "4667", search_criteria: "#{SORTBY_RANK}&familyids[]=4667"),
    GameSearch.new(prefix: "abstract", listid: "4666", search_criteria: "#{SORTBY_RANK}&familyids[]=4666"),
    GameSearch.new(prefix: "family", listid: "5499", search_criteria: "#{SORTBY_RANK}&familyids[]=5499"),
    GameSearch.new(prefix: "thematic", listid: "5496", search_criteria: "#{SORTBY_RANK}&familyids[]=5496"),
    GameSearch.new(prefix: "party", listid: "5498", search_criteria: "#{SORTBY_RANK}&familyids[]=5498"),
    GameSearch.new(prefix: "war", listid: "4664", search_criteria: "#{SORTBY_RANK}&familyids[]=4664"),
    GameSearch.new(prefix: "strategy", listid: "5497", search_criteria: "#{SORTBY_RANK}&familyids[]=5497"),
    GameSearch.new(prefix: "solo", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=1&range[maxplayers][min]=1&playerrangetype=normal"),
    GameSearch.new(prefix: "player_1", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=1&range[maxplayers][min]=1&playerrangetype=normal"),
    GameSearch.new(prefix: "player_2", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=2&range[maxplayers][min]=2&playerrangetype=normal"),
    GameSearch.new(prefix: "player_3", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=3&range[maxplayers][min]=3&playerrangetype=normal"),
    GameSearch.new(prefix: "player_4", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=4&range[maxplayers][min]=4&playerrangetype=normal"),
    GameSearch.new(prefix: "player_5", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=5&range[maxplayers][min]=5&playerrangetype=normal"),
    GameSearch.new(prefix: "player_6", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=6&range[maxplayers][min]=6&playerrangetype=normal"),
    GameSearch.new(prefix: "player_7", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=7&range[maxplayers][min]=7&playerrangetype=normal"),
    GameSearch.new(prefix: "player_8", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=8&range[maxplayers][min]=8&playerrangetype=normal"),
    GameSearch.new(prefix: "player_9", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=9&range[maxplayers][min]=9&playerrangetype=normal"),
    GameSearch.new(prefix: "player_10", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=10&range[maxplayers][min]=10&playerrangetype=normal"),
    GameSearch.new(prefix: "player_11", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=11&range[maxplayers][min]=11&playerrangetype=normal"),
    GameSearch.new(prefix: "player_12", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=12&range[maxplayers][min]=12&playerrangetype=normal"),
    GameSearch.new(prefix: "one_player", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=1&range[maxplayers][min]=1&playerrangetype=exclusive"),

    *(Categories::MECHANICS.map { |prefix, listid| CategoryGames.new(prefix:, listid:, object_type: "property") }),
    *(Categories::FAMILIES.map { |prefix, listid| CategoryGames.new(prefix:, listid:, object_type: "family") }),
  ]
end
