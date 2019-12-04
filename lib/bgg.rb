require_relative 'dependencies'

class Bgg
  NUMBER_OF_MONTHS = 12

  def display_game?(game)
    return false if !game.ts_added
    return false if !game.rank.to_i.between?(1, 300)
    return false if game.player_count.to_i < 1

    true
  end

  def run
    @months = months_display

    @games = snake
      .merge(top_played) { |key, game1, game2| merge_ostructs(game1, game2) }
      .merge(top_ranked) { |key, game1, game2| merge_ostructs(game1, game2) }
      .values
      .select(&method(:display_game?))
      .sort_by(&method(:rank))

    write_output
  end

  def months_display
    first = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.key, g] }.to_h
  end

  def merge_ostructs(ostruct1, ostruct2)
    OpenStruct.new(ostruct1.to_h.merge(ostruct2.to_h))
  end

  def rank(game)
    [
      game.location.blank?.to_s,
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
