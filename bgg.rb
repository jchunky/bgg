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
    # return game.played?
    # return game.own?
    # return game.ownership.present?

    return false unless game.coop? || game.solitaire? || game.max_player_count == 1

    # return false if game.max_player_count == 1
    # return false if game.max_player_count == 2 && !game.coop?
    return false if game.action_points?
    return false if game.app?
    return false if game.dexterity?
    return false if game.flicking?
    return false if game.flip_and_write?
    return false if game.realtime?
    return false if game.roll_and_write?
    return false if game.stacking?
    return false if game.traitor?
    return false if game.war?
    return false if game.wargame?

    # return false unless game.min_player_count.in?(1..2)
    # return false unless game.rank.in?(1..1000)
    # return false unless game.rating.in?(7..)
    # return false unless game.rating_count.in?(1000..)
    # return false unless game.unique_users.in?(100..)
    # return false unless game.vote_rank.in?(1..1000)
    # return false unless game.weight.in?(..2.5)
    return false unless game.max_playtime.in?(1..60)
    return false unless game.play_rank.in?(1..)
    return false unless game.year.in?(2010..)

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
    @all_games ||= begin
      Downloaders::DOWNLOADERS
        .reduce({}) { |hash, downloader|
          hash.merge(by_key(downloader), &method(:merge_hashes))
        }
        .values
        .select { |g| g.rank.positive? }
        .sort_by(&:rank)
        .uniq(&:name)
    end
  end

  def by_key(clazz)
    clazz.games.to_h { |g| [g.key, g] }
  end

  def merge_hashes(_key, game1, game2)
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
