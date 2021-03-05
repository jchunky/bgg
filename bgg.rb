require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  NUMBER_OF_MONTHS = 15
  PLAY_RANK_THRESHOLD = 100
  YEARS_OLD = 6
  MAX_GAME_YEAR = TopPlayed.last_month.year - YEARS_OLD

  def display_game?(game)
    return false if game.rank < 1
    return false if game.play_rank < 1
    return false if Bga::BGA_GAMES.include?(game.name)

    return false unless game.was_in_top_100?

    # return false unless game.in_top_100?

    true
  end

  def run
    @months = TopPlayed.months_data

    @games = all_games
      .select(&method(:display_game?))
      .sort_by { |g| [-g.year, g.play_rank] }

    write_output
  end

  def self.player_rank(play_rank)
    play_rank.to_i.between?(1, 100) ? 2 : 1
  end

  private

  def all_games
    @all_games ||= top_ranked
      .merge(top_played, &method(:merge_hashes))
      .values
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.key, g] }.to_h
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
