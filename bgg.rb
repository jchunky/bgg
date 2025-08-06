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
    # return false unless !game.abstract?
    return false unless !game.ccg?
    return false unless !game.child?
    return false unless !game.party?
    return false unless !game.war?

    # return false unless !game.crowdfunded?
    # return false unless !game.escaperoom?
    return false unless !game.dexterity?
    return false unless !game.digital_hybrid?
    return false unless !game.realtime?
    return false unless !game.werewolf?

    # return false unless !game.played?

    # BGA
    return false unless game.bga?
    return false unless game.min_player_count == 1

    # BGB
    # return false unless game.bgb?
    # return false unless game.play_rank?
    # return false unless game.soloable?
    # return false unless game.price.to_i >= 1
    # return false unless game.normalized_price.to_f.round < 50

    # B2GO
    # return false unless game.b2go?
    # return false unless game.play_rank?
    # return false unless game.soloable?

    # Snakes
    # return false unless game.snakes?
    # return false unless game.snakes_category <= 22
    # return false unless game.play_rank?

    # return false unless game.snakes? || game.bga? || game.b2go?
    # return false unless game.soloable?

    # return false unless game.coop?
    # return false unless game.couples?
    # return false unless game.solo?
    # return false unless game.bga?
    # return false unless game.bgb?
    # return false unless game.b2go?
    # return false unless game.soloable?
    # return false unless game.min_player_count == 1
    # return false unless game.max_player_count >= 4
    # return false unless game.price.to_i >= 1
    # return false unless game.normalized_price.to_f.round < 50
    # return false unless game.play_rank?
    # return false unless game.playtime < 100
    # return false unless game.weight.round(1) < 3

    true
  end

  def run
    Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    @games = all_games
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

  def float(value, decimals:)
    value.to_f.zero? ? "" : format("%0.#{decimals}f", value)
  end
end

Bgg.new.run
