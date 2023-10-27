require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  MAX_GAME_YEAR = Date.today.year - 5
  DOWNLOADERS = [
    GameSearch.new(prefix: "bgg", search_criteria: "sort=rank"),
    GameSearch.new(prefix: "vote", search_criteria: "sort=numvoters&sortdir=desc"),

    GameSearch.new(prefix: "light", search_criteria: "sort=rank&floatrange[avgweight][max]=3"),

    GameSearch.new(prefix: "solo", search_criteria: "sort=rank&range[minplayers][max]=1"),
    GameSearch.new(prefix: "five_player", search_criteria: "sort=rank&playerrangetype=normal&range[maxplayers][min]=5"),

    GameSearch.new(prefix: "coop", search_criteria: "sort=rank&propertyids[0]=2023"),
    GameSearch.new(prefix: "campaign", search_criteria: "sort=rank&propertyids[0]=2822"),
    GameSearch.new(prefix: "card_driven", search_criteria: "sort=rank&propertyids[0]=2018"),
    GameSearch.new(prefix: "dice", search_criteria: "sort=rank&propertyids[0]=2072"),
    GameSearch.new(prefix: "legacy", search_criteria: "sort=rank&propertyids[0]=2824"),
    GameSearch.new(prefix: "storytelling", search_criteria: "sort=rank&propertyids[0]=2027"),

    GameSearch.new(prefix: "abstract", search_criteria: "sort=rank&familyids[0]=4666"),
    GameSearch.new(prefix: "child", search_criteria: "sort=rank&familyids[0]=4665"),
    GameSearch.new(prefix: "customizable", search_criteria: "sort=rank&familyids[0]=4667"),
    GameSearch.new(prefix: "family", search_criteria: "sort=rank&familyids[0]=5499"),
    GameSearch.new(prefix: "party", search_criteria: "sort=rank&familyids[0]=5498"),
    GameSearch.new(prefix: "strategy", search_criteria: "sort=rank&familyids[0]=5497"),
    GameSearch.new(prefix: "thematic", search_criteria: "sort=rank&familyids[0]=5496"),
    GameSearch.new(prefix: "war", search_criteria: "sort=rank&familyids[0]=4664"),
  ]

  def display_game?(game)
    return false unless game.card_driven_rank > 0 || game.campaign_rank > 0
    return false unless game.coop_rank > 0
    # return false unless game.light_rank > 0
    return false unless game.rank > 0
    return false unless game.rank.between?(1, 1000)
    return false unless game.solo_rank > 0
    return false unless game.vote_rank > 0

    return true
  end

  def run
    @games = all_games
      .select(&method(:display_game?))
      .sort_by { |g| [-g.year, g.rank] }

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
