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
    TopPlayed,
    TopRanked,
    TopVoted,
    TopCouples,
    TopSolo,
  ]

  def display_game?(game)
    return false unless game.year.to_i < MAX_GAME_YEAR

    # return false unless game.couples_rank > 0
    # return false unless game.couples_rank > 0 || game.solo_rank > 0
    # return false unless game.couples_rank == 0 && game.solo_rank > 0
    return false unless game.couples_rank > 0 && game.solo_rank == 0

    return false unless game.play_rank.between?(1, 200)
    return false unless game.rank.between?(1, 1000)
    return false unless game.vote_rank > 0

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
    clazz.new.games.to_h { |g| [g.key, g] }
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
