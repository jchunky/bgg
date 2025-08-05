module Downloaders
  class PlayedData
    def prefix = :played_data
    def listid = "played_data"

    def games
      @games ||= File
        .read("./data/played_games.txt")
        .split("\n")
        .map { |data| build_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

    def build_game(name)
      Game.new(
        name:,
        played: true,
      )
    end
  end
end
