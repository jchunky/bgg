# TODO:
# - upgrade sortanle
# - use cdn for sortable
# - use struct for categories

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"

Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  include Categories

  MAX_GAME_YEAR = Date.today.year - 5

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

    GeekList.new(prefix: 'couples', listid: 307302),
    GeekList.new(prefix: 'solo', listid: 306154),

    GameSearch.new(prefix: "bgg", search_criteria: "#{SORTBY_RANK}"),
    GameSearch.new(prefix: "vote", search_criteria: "#{SORTBY_VOTES}"),

    *WEIGHT_SEARCHES,
    *PLAYER_COUNT_SEARCHES,
    *MECHANIC_SEARCHES,
    *SUBDOMAIN_SEARCHES,
  ]

  def display_game?(game)
    return false unless game.coop?
    return false unless game.play_rank > 0
    # return false unless game.rank.between?(1, 1000)
    return false unless game.solo?
    # return false unless game.solo_rank > 0
    # return false unless game.vote_rank > 0

    return true
  end

  def run
    @games = all_games
      .select(&method(:display_game?))
      .sort_by { |g| [-g.year, g.play_rank] }

    write_output
  end

  private

  def all_games
    result = DOWNLOADERS
      .reduce({}) do |hash, downloader|
        hash.merge(by_key(downloader), &method(:merge_hashes))
      end
      .values

    result
      .select { |g| g.votes_per_year.positive? }
      .sort_by { |g| -g.votes_per_year }
      .each_with_index { |g, i| g.votes_per_year_rank = i + 1 }

    result
  end

  def by_key(clazz)
    clazz.games.to_h { |g| [g.key, g] }
  end

  def merge_hashes(_key, game1, game2)
    game1.merge(game2)
  end

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end
end

Bgg.new.run
