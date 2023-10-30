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

  NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
  SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank"
  SORTBY_VOTES = "#{NO_EXPANSIONS}&sort=numvoters&sortdir=desc"

  DOWNLOADERS = [
    TopPlayed.new,

    GeekList.new(prefix: 'couples', listid: 307302),
    GeekList.new(prefix: 'solo', listid: 306154),

    GameSearch.new(prefix: "bgg", search_criteria: "#{SORTBY_RANK}"),
    GameSearch.new(prefix: "vote", search_criteria: "#{SORTBY_VOTES}"),

    GameSearch.new(prefix: "weight_1_0", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=1.0&floatrange[avgweight][max]=1.5"),
    GameSearch.new(prefix: "weight_1_5", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=1.5&floatrange[avgweight][max]=2.0"),
    GameSearch.new(prefix: "weight_2_0", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=2.0&floatrange[avgweight][max]=2.5"),
    GameSearch.new(prefix: "weight_2_5", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=2.5&floatrange[avgweight][max]=3.0"),
    GameSearch.new(prefix: "weight_3_0", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=3.0&floatrange[avgweight][max]=3.5"),
    GameSearch.new(prefix: "weight_3_5", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=3.5&floatrange[avgweight][max]=4.0"),
    GameSearch.new(prefix: "weight_4_0", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=4.0&floatrange[avgweight][max]=4.5"),
    GameSearch.new(prefix: "weight_4_5", search_criteria: "#{SORTBY_RANK}&floatrange[avgweight][min]=4.5&floatrange[avgweight][max]=5.0"),

    GameSearch.new(prefix: "player_count_1", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=1&range[minplayers][max]=1"),
    GameSearch.new(prefix: "player_count_2", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=2&range[minplayers][max]=2"),
    GameSearch.new(prefix: "player_count_3", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=3&range[minplayers][max]=3"),
    GameSearch.new(prefix: "player_count_4", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=4&range[minplayers][max]=4"),
    GameSearch.new(prefix: "player_count_5", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=5&range[minplayers][max]=5"),
    GameSearch.new(prefix: "player_count_6", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=6&range[minplayers][max]=6"),
    GameSearch.new(prefix: "player_count_7", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=7&range[minplayers][max]=7"),
    GameSearch.new(prefix: "player_count_8", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=8&range[minplayers][max]=8"),
    GameSearch.new(prefix: "player_count_9", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=9&range[minplayers][max]=9"),
    GameSearch.new(prefix: "player_count_10", search_criteria: "#{SORTBY_RANK}&playerrangetype=normal&range[maxplayers][min]=10&range[minplayers][max]=10"),

    GameSearch.new(prefix: "coop", search_criteria: "#{SORTBY_RANK}&propertyids[0]=2023"),
    GameSearch.new(prefix: "campaign", search_criteria: "#{SORTBY_RANK}&propertyids[0]=2822"),
    GameSearch.new(prefix: "card_driven", search_criteria: "#{SORTBY_RANK}&propertyids[0]=2018"),
    GameSearch.new(prefix: "dice", search_criteria: "#{SORTBY_RANK}&propertyids[0]=2072"),
    GameSearch.new(prefix: "legacy", search_criteria: "#{SORTBY_RANK}&propertyids[0]=2824"),
    GameSearch.new(prefix: "storytelling", search_criteria: "#{SORTBY_RANK}&propertyids[0]=2027"),

    GameSearch.new(prefix: "thematic", search_criteria: "#{SORTBY_RANK}&familyids[0]=5496"),
    GameSearch.new(prefix: "abstract", search_criteria: "#{SORTBY_RANK}&familyids[0]=4666"),
    GameSearch.new(prefix: "child", search_criteria: "#{SORTBY_RANK}&familyids[0]=4665"),
    GameSearch.new(prefix: "customizable", search_criteria: "#{SORTBY_RANK}&familyids[0]=4667"),
    GameSearch.new(prefix: "family", search_criteria: "#{SORTBY_RANK}&familyids[0]=5499"),
    GameSearch.new(prefix: "party", search_criteria: "#{SORTBY_RANK}&familyids[0]=5498"),
    GameSearch.new(prefix: "strategy", search_criteria: "#{SORTBY_RANK}&familyids[0]=5497"),
    GameSearch.new(prefix: "war", search_criteria: "#{SORTBY_RANK}&familyids[0]=4664"),
  ]

  def display_game?(game)
    return false unless game.campaign? || game.card_driven? || game.storytelling?
    return false unless game.coop?
    return false unless game.play_rank > 0
    return false unless game.rank.between?(1, 1000)
    return false unless game.solo?

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
