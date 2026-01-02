require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "ostruct"
require "uri"
require "yaml"

Dir["lib/**/*.rb"].each { |f| require_relative f }

class Bgg
  def display_game?(game)
    return false unless !game.banned?
    return false unless !game.party?
    return false unless !game.played?

    return false unless game.b2go?
    # return false unless game.bga?
    # return false unless game.bgb?
    # return false unless game.snakes?

    # Solable
    # return false unless game.min_player_count == 1
    # return false unless game.play_rank? | game.soloable?

    # return false unless game.storytelling? || game.cyoa? || game.campaign?
    # return false unless game.b2go_price < 20
    # return false unless game.coop?
    # return false unless game.max_player_count == 1
    # return false unless game.max_player_count.between?(1, 2)
    return false unless game.min_player_count == 1
    # return false unless game.normalized_price < 30
    # return false unless game.normalized_price > 0
    # return false unless game.normalized_price >= 30
    # return false unless game.offer_count.to_i >= 10
    # return false unless game.play_rank.between?(1, 100)
    return false unless game.play_rank?
    # return false unless game.player_count_range.cover?(2)
    # return false unless game.playtime.between?(1, 99)
    # return false unless game.rank.between?(1, 500)
    # return false unless game.rank.to_i > 0
    # return false unless game.solitaire?
    # return false unless game.soloable?
    # return false unless game.soloable? || game.min_player_count == 0
    # return false unless game.thematic?
    # return false unless game.vote_rank.between?(1, 500)
    # return false unless game.votes_per_year_rank.between?(1, 500)
    # return false unless game.weight.round(1) < 3
    # return false unless game.year >= Time.now.year - 5

    true
  end

  def run
    Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    @games = all_games
      .sort_by { |g| -g.votes_per_year }
      .each.with_index(1) { |g, i| g.votes_per_year_rank = i }
      .sort_by { |g| -g.rating_count }
      .each.with_index(1) { |g, i| g.rating_count_rank = i }
      .select { display_game?(_1) }
      .sort_by { |g| [-g.year.to_i, g.rank] }

    write_output
  end

  private

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end

  def all_games
    @all_games ||= Downloaders::DOWNLOADERS
      .flat_map(&:games)
      .group_by(&:key)
      .transform_values { |games| games.reduce { |game1, game2| game1.merge(game2) } }
      .values
      .select { |game| game.rank.positive? }
      .sort_by(&:rank)
      .uniq(&:name)
  end

  def int(value)
    value.to_i.zero? ? "" : value
  end

  def float(value, decimals: 1)
    value.to_f.zero? ? "" : format("%0.#{decimals}f", value)
  end
end

Bgg.new.run
