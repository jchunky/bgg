require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  YEARS_OLD = 6
  MAX_GAME_YEAR = Date.today.year - YEARS_OLD
  DOWNLOADERS = [
    TopChildren,
    TopFamily,
    TopParty,
    TopPlayed,
    TopRanked,
    TopStrategy,
    TopThematic,
    TopVoted,
  ]

  def display_game?(game)
    return false if game.play_rank < 1
    return false if game.rank < 1
    return false if game.vote_rank < 1

    # return game.children_rank >= 1
    # return game.family_rank >= 1
    # return game.party_rank >= 1
    # return game.strategy_rank >= 1
    # return game.thematic_rank >= 1

    return false unless game.play_rank.between?(1, 200)
    return false unless game.vote_rank.between?(1, 1000)
    return false unless game.rank.between?(1, 1000)

    true
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
