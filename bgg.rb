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
    # return game.play_rank >= 1 && (game.rank_children >= 1 || game.voter_rank_children >= 1)
    # return game.play_rank >= 1

    return false if game.play_rank < 1
    return false if game.rank < 1
    return false if game.voter_rank < 1

    return false if game.play_rank > 100
    return false if game.voter_rank > 100

    true
  end

  def run
    @games = all_games
      .select(&method(:display_game?))
      .sort_by { |g| [-g.year, g.play_rank] }

    write_output
  end

  def self.player_rank(play_rank)
    play_rank.to_i.between?(1, PLAY_RANK_THRESHOLD) ? 2 : 1
  end

  private

  def all_games
    @all_games ||= top_voted
      .merge(top_voted_children, &method(:merge_hashes))
      .merge(top_ranked, &method(:merge_hashes))
      .merge(top_played, &method(:merge_hashes))
      .merge(top_ranked_children, &method(:merge_hashes))
      .values
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_voted
    @top_voted ||= TopVoted.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_voted_children
    @top_voted_children ||= TopVotedChildren.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_ranked_children
    @top_ranked_children ||= TopRankedChildren.new.games.map { |g| [g.key, g] }.to_h
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
