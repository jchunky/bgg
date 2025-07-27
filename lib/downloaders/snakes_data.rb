module Downloaders
  class SnakesData
    def prefix = :snakes_data
    def listid = "snakes_data"

    def games
      @games ||= File
        .read("./data/snakes.txt")
        .then { |data| data =  data.gsub(/All Games\nAnnex\nCollege\nTempe\nChicago\nTucson\nCategory\nA\/Z\nSearch\n\n.*\n.*Location/, '') }
        .then { |data| chunk_games(data) }
        .map { |game_data| build_game(game_data) }
        .reject { |game| game.name.blank? }
    end

    private

    def chunk_games(data)
      data = data
        .strip
        .split("\n")
        .reject(&:blank?)


      data.each_with_index
        .slice_after { match_location?(data, _1, _2) }
        .map { |game_data| game_data.map(&:first) }
    end

    def match_location?(data, line, i)
      line = line.downcase

      return false if line == "blokus 3d"
      return true if data[i + 1] && data[i + 1] == data[i + 2]

      line.match?(/\b\d{1,2}[a-f]\b/) ||
        line.include?("archives") ||
        line.include?("new arrivals") ||
        line.include?("retired") ||
        line.include?("staff picks") ||
        line == "1Ω" ||
        line == "culled" ||
        line == "mia" ||
        line == "post" ||
        line == "prep" ||
        line == "rpg" ||
        line == "sickbay"
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
