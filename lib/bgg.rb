require_relative 'dependencies'

class Bgg
  WHITELIST = [
    # "Onitama",
  ]

  def display_game?(game)
    return true if WHITELIST.include?(game[:name])
    return true if game[:ts_added].to_s > "2019-10-08"
    return false if game[:player_count].to_i < 1
    return false unless game[:ts_added]
    return false if game[:location].to_i.between?(1, 19)
    return false if game[:location] == "Archives"
    return false if game[:shelf_category] == "Bluffing"
    return false if game[:shelf_category] == "Co-op"
    return false if game[:shelf_category] == "Deck Builder"
    # return false if game[:voters].to_i < 3000
    # return false if game[:player_count].to_i < 1
    # return false if game[:rating].to_f < 7.5
    true
  end

  def run
    @games = snake
      .merge(top_played) { |key, game1, game2| game1.merge(game2) }
      .merge(top_ranked) { |key, game1, game2| game1.merge(game2) }
      .values
      .select(&method(:display_game?))
      .sort_by { |g| g[:rank].to_i }

    write_output
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g[:key], g] }.to_h
  end

  def rank(game)
    [
      game[:location].blank?.to_s,
      -game[:player_count].to_i,
      game[:name]
    ]
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end
end

Bgg.new.run
