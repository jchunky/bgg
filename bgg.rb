require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"

Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  def display_game?(game)
    return false unless game.coop? || game.max_player_count == 1
    return false unless game.min_player_count == 1

    return false unless game.max_playtime.in?(1..60)
    return false unless game.play_rank.in?(1..)

    return false unless game.replays.in?(10..)

    true
  end

  def run
    Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    @games = all_games
      .select(&method(:display_game?))
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
      .flat_map { |downloader| downloader.games }
      .group_by(&:key)
      .transform_values { |games| games.reduce(&method(:merge_games)) }
      .values
      .select { |game| game.rank.positive? }
      .sort_by(&:rank)
      .uniq(&:name)
  end

  def by_key(clazz)
    clazz.games.to_h { |g| [g.key, g] }
  end

  def merge_games(game1, game2)
    game1.merge(game2)
  end

  def int(value)
    value.to_i.zero? ? "" : value
  end

  def float(value)
    value.to_f.zero? ? "" : format("%0.2f", value)
  end
end

Bgg.new.run
