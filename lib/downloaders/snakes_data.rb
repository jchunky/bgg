module Downloaders
  class SnakesData < Base
    SHELF_PATTERN = /\b\d{1,2}[a-f]\b/
    LOCATION_KEYWORDS = %w[archives new\ arrivals retired staff\ picks].freeze
    TERMINAL_LOCATIONS = %w[culled mia post prep rpg sickbay].freeze
    NAV_HEADER = %r{All Games\nAnnex\nCollege\nTempe\nChicago\nTucson\nCategory\nA/Z\nSearch\n\n.*\n.*Location}

    def prefix = :snakes_data
    def listid = "snakes_data"

    def games
      @games ||= File
        .read("./data/snakes.txt")
        .then { |data| data.gsub(NAV_HEADER, "") }
        .then { |data| chunk_games(data) }
        .filter_map { |game_data| Parsers::SnakesGame.parse(game_data) }
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

      line.match?(SHELF_PATTERN) ||
        LOCATION_KEYWORDS.any? { line.include?(it) } ||
        TERMINAL_LOCATIONS.include?(line)
    end
  end
end
