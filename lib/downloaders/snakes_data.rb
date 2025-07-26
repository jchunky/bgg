module Downloaders
  class SnakesData
    def prefix = :snakes_data
    def listid = "snakes_data"

    def games
      @games ||= File
        .read("./data/snakes.txt")
        .then { |data| data =  data.gsub(/All Games\nAnnex\nCollege\nTempe\nChicago\nTucson\nCategory\nA\/Z\nSearch\n\n.*\n.*Location/, '') }
        .then { |data| chunk_games(data) }
        .tap { |data| data.sort_by(&:first).each { |g| p g } }
        .map { |game_data| build_game(game_data) }
        .reject { |game| game.name.blank? }
    end

    private

    def chunk_games(data)
      data
        .strip
        .split("\n")
        .reject(&:blank?)
        .slice_after do |line|
          line = line.downcase

          line != "blokus 3d" &&
            line.match?(/\b\d{1,2}[a-f]\b/) ||
            line.include?("archives") ||
            line.include?("staff picks") ||
            line.include?("retired") ||
            line.include?("new arrivals") ||
            line == "rpg" ||
            line == "culled" ||
            line == "mia" ||
            line == "post" ||
            line == "prep"
        end
    end

    def build_game(game_data)
      name, *, location = game_data

      Game.new(
        name:,
        snakes_location: normalize_location(location),
        snakes: true,
      )
    end

    def normalize_location(location)
      match = location.scan(/\b\d+\w\b/).first
      return location unless match

      match
    end
  end
end
