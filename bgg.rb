require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "ostruct"
require "uri"
require "yaml"

require_relative "lib/loader"
Loader.setup

class Bgg
  def run
    Config::Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    @games = all_games
      .sort_by { |g| -g.votes_per_year }
      .each.with_index(1) { |g, i| g.votes_per_year_rank = i }
      .sort_by { |g| -g.rating_count }
      .each.with_index(1) { |g, i| g.rating_count_rank = i }
      .select(&:displayable?)
      .sort_by { |g| [-g.weight] }

    write_output
  end

  private

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end

  def all_games
    @all_games ||= Config::Downloaders::DOWNLOADERS
      .flat_map(&:games)
      .group_by(&:key)
      .transform_values { |games| games.reduce { |game1, game2| game2.merge(game1) } }
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
