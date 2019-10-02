require_relative 'dependencies'

class Bgg
  MAX_RANK = 500
  MIN_PLAYERS = 500
  MIN_VOTERS = 10_000

  def display_game?(game)
    return false if game.rank.to_i > 500
    return false if game.player_count.to_i < 500
    return false if game.voters.to_i < 10_000
    # return false if game.rating.to_f < 7.5
    true
  end

  def run
    @games = top_played
      .merge(top_ranked) { |name, game1, game2| merge_ostructs(game1, game2) }
      .values
      .select(&method(:display_game?))
      .sort_by(&method(:rank))

    write_output
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.name, g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.name, g] }.to_h
  end

  def merge_ostructs(ostruct1, ostruct2)
    OpenStruct.new(ostruct1.to_h.merge(ostruct2.to_h))
  end

  def rank(game)
    [
      -game.player_count.to_i,
      game.name
    ]
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end
end

Bgg.new.run
