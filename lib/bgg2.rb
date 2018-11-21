require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'games/snake'
require_relative 'games/top_played'
require_relative 'games/top_ranked'
require_relative 'utils'

class Bgg2
  def run
    top_played = TopPlayed.new.games
    top_ranked = TopRanked.new.games
    snake_games = Snake.new.games

    games = top_played.map { |g| [g.key, g] }.to_h

    top_ranked.each do |game|
      if games.include?(game.key)
        game.player_count = games[game.key].player_count
      end
      games[game.key] = game
    end

    snake_games.each do |g|
      if games.include?(g.key)
        game = games[g.key]
        name = game.name
        g.to_h.each { |k, v| game[k] = v }
        game.name = name
      else
        games[g.key] = g
      end
    end

    @games = games
      .values
      .select { |game| display_game?(game) }
      .sort_by { |g| [g.location.blank?.to_s, -g.player_count.to_i, g.name] }

    write_output
  end

  def write_output
    template = File.read('views/bgg2.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg2.html', html)
  end

  def display_game?(game)
    return false unless game.location
    return true if game.ts_added > "2018-11-01"
    return false if game.categories.include?("Nostalgia")
    return false if game.categories.include?("Dexterity")
    return false if game.categories.include?("Greatest Hits")
    return false if game.player_count.to_i < 100
    return false if game.rank.to_i > 2500
    true
  end
end

Bgg2.new.run
