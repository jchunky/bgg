require_relative "game_search"
require_relative "geek_list"
require_relative "top_played"

module Downloaders
  include Categories

  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"

  MECHANIC_SEARCHES = MECHANICS.map do |mechanic, mechanic_id|
    GameSearch.new(prefix: mechanic, search_criteria: "#{SORTBY_RANK}&propertyids[0]=#{mechanic_id}")
  end

  SUBDOMAIN_SEARCHES = SUBDOMAINS.map do |subdomain, subdomain_id|
    GameSearch.new(prefix: subdomain, search_criteria: "#{SORTBY_RANK}&familyids[0]=#{subdomain_id}")
  end

  PLAYER_COUNT_SEARCHES = PLAYER_COUNT_FIELDS.map do |name, i|
    GameSearch.new(prefix: name, search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=#{i}&range[minplayers][max]=#{i}")
  end

  WEIGHT_SEARCHES = WEIGHT_FIELDS.map do |name, i|
    GameSearch.new(prefix: name, search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=#{i}&floatrange[avgweight][max]=#{i + 0.5}")
  end

  DOWNLOADERS = [
    TopPlayed.new,

    GeekList.new(prefix: 'corridor', listid: 324833),
    GeekList.new(prefix: 'couples', listid: 307302),
    GeekList.new(prefix: 'solo', listid: 306154),

    GameSearch.new(prefix: "bgg", search_criteria: "#{SORTBY_RANK}"),
    GameSearch.new(prefix: "vote", search_criteria: "#{SORTBY_VOTES}"),

    *WEIGHT_SEARCHES,
    *PLAYER_COUNT_SEARCHES,
    *MECHANIC_SEARCHES,
    *SUBDOMAIN_SEARCHES,
  ]
end
