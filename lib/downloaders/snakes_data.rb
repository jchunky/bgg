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
      lines = data.lines.map(&:strip).reject(&:empty?)
      chunks = []
      i = 0

      while i < lines.size - 1
        if lines[i] == lines[i + 1]
          title = lines[i]
          chunk = [title]
          i += 2

          # Collect detail lines until we hit the next title pair or run out
          details = []
          while i < lines.size
            # If we're at a new repeated title, break
            break if i + 1 < lines.size && lines[i] == lines[i + 1]
            details << lines[i]
            i += 1
          end

          chunks << (chunk + details)
        else
          i += 1
        end
      end

      chunks
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
