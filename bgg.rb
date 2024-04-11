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

  def display_game?(game)
    return false unless game.play_rank > 0

    return false unless game.campaign?
    return false unless game.coop?
    return false unless game.solo?

    return false if game.action_points?
    return false if game.app?
    # return false if game.bga?
    # return false if game.crowdfunding?
    # return false if game.dice?
    return false if game.flicking?
    return false if game.realtime?
    return false if game.stacking?
    # return false if game.storytelling?

    # return false unless game.weight < 3

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

  def all_games
    result = Downloaders::DOWNLOADERS
      .reduce({}) do |hash, downloader|
        hash.merge(by_key(downloader), &method(:merge_hashes))
      end
      .values

    result
      .select { |g| g.votes_per_year.positive? }
      .sort_by { |g| -g.votes_per_year }
      .each_with_index { |g, i| g.votes_per_year_rank = i + 1 }

    result
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
