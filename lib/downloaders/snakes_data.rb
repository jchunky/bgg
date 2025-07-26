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
      data
        .strip
        .split("\n")
        .slice_after do |line|
          line != "Blokus 3D" &&
          line.match?(/\b\d{1,2}[A-F]\b/) ||
          line.include?("Archives") ||
          line.include?("Staff Picks") ||
          line.include?("Retired") ||
          line.include?("New Arrivals") ||
          line == "MIA" ||
          line == "Post" ||
          line == "Prep"
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
