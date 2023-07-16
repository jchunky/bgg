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
    TopPlayed.new,
    GameSearch.new(prefix: "vote", search_criteria: "sort=numvoters&sortdir=desc"),
    GameSearch.new(prefix: "bgg", search_criteria: "sort=rank"),
    GameSearch.new(prefix: "child", search_criteria: "sort=rank&familyids[0]=4665"),
    GameSearch.new(prefix: "campaign", search_criteria: "sort=rank" +
      "&floatrange[avgweight][max]=3" + # weight <= 3
      "&range[minplayers][max]=1" + # 1-player
      "&propertyids[0]=2023" + # cooperative
      "&propertyids[1]=2822" + # scenario / mission / campaign game
      "&nopropertyids[0]=2027" # no 'storytelling'
    ),
    GeekList.new(prefix: 'couples', listid: 307302),
    GeekList.new(prefix: 'solo', listid: 306154),
  ]

  def display_game?(game)
    return false unless game.play_rank > 0

    # return false unless game.year.to_i < MAX_GAME_YEAR
    # return false unless game.couples_rank > 0
    # return false unless game.vote_rank > 0
    # return false unless game.play_rank.between?(1, 200)
    # return false unless game.rank.between?(1, 1000)

    # return false unless game.solo_rank > 0

    return false unless game.campaign_rank > 0

    # return false unless game.child_rank > 0

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
    DOWNLOADERS.reduce({}) do |hash, downloader|
      hash.merge(by_key(downloader), &method(:merge_hashes))
    end.values
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
