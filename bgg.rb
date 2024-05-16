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
    # return game.own?

    # return false unless game.campaign?
    return false unless game.player_1?
    return false unless game.coop?

    # return false if game.bga?
    # return false if game.ccg?
    # return false if game.deck_building?
    # return false if game.legacy?
    # return false if game.solitaire?
    # return false if game.tableau_building?
    # return false if game.worker_placement?
    return false if game.action_points?
    return false if game.app?
    return false if game.flicking?
    return false if game.flip_and_write?
    return false if game.realtime?
    return false if game.stacking?

    return false unless game.play_rank > 0
    return false unless game.rank.in?(1..5000)
    return false unless game.vote_rank.in?(1..5000)
    return false unless game.rating >= 7
    return false unless game.weight.between?(1.5, 3)
    return false unless game.year >= 2010

    # return false unless game.replays >= 12

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
    @all_games ||= begin
      result = Downloaders::DOWNLOADERS
        .reduce({}) do |hash, downloader|
          hash.merge(by_key(downloader), &method(:merge_hashes))
        end
        .values

      result = result
        .select { |g| g.rank.positive? }
        .sort_by(&:rank)
        .uniq(&:name)

      top_played = result.select { |g| g.play_rank.positive? }

      top_played
        .select { |g| g.replays.positive? }
        .sort_by { |g| -g.replays }
        .each_with_index { |g, i| g.replay_rank = i + 1 }
        .tap { |games| @replays_lower_bound = games[-100].replays }
        .tap { |games| @replays_upper_bound = games[100].replays }

      top_played
        .select { |g| g.rating.positive? }
        .sort_by { |g| -g.rating }
        .each_with_index { |g, i| g.rating_rank = i + 1 }
        .tap { |games| @rating_lower_bound = games[-100].rating }
        .tap { |games| @rating_upper_bound = games[100].rating }

      top_played
        .select { |g| g.weight.positive? }
        .sort_by { |g| -g.weight }
        .each_with_index { |g, i| g.weight_rank = i + 1 }
        .tap { |games| @weight_lower_bound = games[-100].weight }
        .tap { |games| @weight_upper_bound = games[100].weight }

      top_played
        .select { |g| g.year.positive? }
        .sort_by { |g| -g.year }
        .each_with_index { |g, i| g.year_rank = i + 1 }
        .tap { |games| @year_lower_bound = games[-100].year }
        .tap { |games| @year_upper_bound = games[100].year }

      result
    end
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
