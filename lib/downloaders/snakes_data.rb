module Downloaders
  class SnakesData
    def prefix = :snakes_data
    def listid = "snakes_data"

    def games
      @games ||= File
        .read("./data/snakes.txt")
        .then { |data| data =  data.gsub(/All Games\nAnnex\nCollege\nTempe\nChicago\nTucson\nCategory\nA\/Z\nSearch\n\n.*\n.*Location/, '') }
        .then { |data| chunk_games(data) }
        .tap(&method(:find_failed_splits))
        .map { |game_data| build_game(game_data) }
        .reject { |game| game.name.blank? }
    end

    private

    def chunk_games(data)
      data
        .strip
        .split("\n")
        .reject(&:blank?)
        .slice_after(&method(:match_location?))
    end

    def find_failed_splits(data)
      return

      data.each do |g|
        pairs = g.each_cons(2).select { |a, b| a == b }
        p g.to_a if pairs.count >= 2
      end
    end

    def match_location?(line)
      line = line.downcase

      return false if line == "blokus 3d"

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
        line == "sickbay" ||
        false
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
