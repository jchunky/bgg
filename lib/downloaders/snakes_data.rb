module Downloaders
  class SnakesData
    def prefix = :snakes_data
    def listid = "snakes_data"

    def games
      @games ||= File
        .read("./data/snakes.txt")
        .split("\n")
        .each_cons(2)
        .to_a
        .select { |a, b| a == b }
        .map(&:first)
        .map { |name| build_game(name) }
        .reject { |game| game.name.blank? }
    end

    private

    def build_game(name)
      Game.new(
        name:,
        snakes: true,
      )
    end
  end
end
