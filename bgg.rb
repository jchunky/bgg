require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  PLAY_RANK_THRESHOLD = 50
  YEARS_OLD = 6
  MAX_GAME_YEAR = Date.today.year - YEARS_OLD

  def display_game?(game)
    # return game.play_rank >= 1 && game.children_rank >= 1
    # return game.play_rank >= 1 && game.thematic_rank >= 1
    return game.play_rank >= 1

    return false if game.play_rank < 1
    return false if game.rank < 1
    return false if game.vote_rank < 1

    return false if game.play_rank > 100
    return false if game.vote_rank > 100

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
    by_key(TopPlayed)
      .merge(by_key(TopChildren), &method(:merge_hashes))
      .merge(by_key(TopRanked), &method(:merge_hashes))
      .merge(by_key(TopThematic), &method(:merge_hashes))
      .merge(by_key(TopVoted), &method(:merge_hashes))
      .values
  end

  def by_key(clazz)
    clazz.new.games.map { |g| [g.key, g] }.to_h
  end

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end

  def merge_hashes(_key, game1, game2)
    game1.merge(game2)
  end
end

Bgg.new.run
