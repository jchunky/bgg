require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"

Dir["lib/**/*.rb"].each { |f| require_relative f }

class Bgg
  def display_game?(game)
    # return false unless game.solo?
    # return false if game.war?
    # return false if game.thematic?
    return false unless game.coop? || game.max_player_count == 1
    return false unless game.min_player_count == 1

    return false unless game.max_playtime.in?(1..60)
    return false unless game.play_rank.in?(1..)
    return false unless game.weight < 2.5
    return false unless game.rank.in?(1..2000)
    # return false unless game.vote_rank.in?(1..)

    # return false unless game.ghi.in?(37..)
    # return false unless game.replays.in?(10..)

    true
  end

  def run
    Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    @games = all_games
      .select { display_game?(_1) }
      .sort_by { |g| [-g.year, g.play_rank] }

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

  def float(value)
    value.to_f.zero? ? "" : format("%0.2f", value)
  end
end

Bgg.new.run
