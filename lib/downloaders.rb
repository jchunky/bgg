require_relative "downloaders/category_games"
require_relative "downloaders/game_search"
require_relative "downloaders/top_played"

module Downloaders
  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"
  CATEGORIES = Categories::CATEGORIES.map { |prefix, listid, items_per_page| CategoryGames.new(prefix: prefix, listid: listid, items_per_page: items_per_page, object_type: "property") }
  MECHANICS = Categories::MECHANICS.map { |prefix, listid, items_per_page| CategoryGames.new(prefix: prefix, listid: listid, items_per_page: items_per_page, object_type: "property") }
  FAMILIES = Categories::FAMILIES.map { |prefix, listid, items_per_page| CategoryGames.new(prefix: prefix, listid: listid, items_per_page: items_per_page, object_type: "family") }
  SUBDOMAINS = Categories::SUBDOMAINS.map { |prefix, listid, items_per_page| CategoryGames.new(prefix: prefix, listid: listid, items_per_page: items_per_page, object_type: "family") }
  PLAYER_COUNTS = (1..12).map do |count|
    GameSearch.new(prefix: :"player_#{count}", listid: "playerrangetype", search_criteria: "#{SORTBY_RANK}&range[minplayers][max]=#{count}&range[maxplayers][min]=#{count}&playerrangetype=normal")
  end
  PLAYTIMES = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240, 300, 360].map do |playtime|
    GameSearch.new(prefix: :"playtime_#{playtime}", listid: "playtime", search_criteria: "#{SORTBY_RANK}&range[playtime][max]=#{playtime}")
  end
  AGES = (2..18).map do |age|
    GameSearch.new(prefix: :"age_#{age}", listid: "minage", search_criteria: "#{SORTBY_RANK}&range[minage][max]=#{age}")
  end
  DOWNLOADERS = [
    TopPlayed.new(prefix: :play, listid: "plays"),
    GameSearch.new(prefix: :bgg, listid: "rank", search_criteria: SORTBY_RANK),
    GameSearch.new(prefix: :vote, listid: "numvoters", search_criteria: SORTBY_VOTES),
    *PLAYER_COUNTS,
    *PLAYTIMES,
    *AGES,
    *CATEGORIES,
    *MECHANICS,
    *FAMILIES,
    *SUBDOMAINS,
  ]
end
