module Downloaders
  class BgoData < Base
    def prefix = :bgo_data
    def listid = "bgo_data"

    def games
      @games ||= File
        .read("./data/bgo.txt")
        .split("\n\n")
        .filter_map { |data| parse_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

    def parse_game(data)
      Parsers::BgoGame.new(data).to_game
    rescue StandardError
      nil
    end
  end
end
