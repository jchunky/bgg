module Downloaders
  class B2goData < Base
    def prefix = :b2go_data
    def listid = "b2go_data"

    def games
      @games ||= File
        .read("./data/b2go.txt")
        .split("\n")
        .each_slice(4)
        .filter_map { |data| parse_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

    def parse_game(data)
      Parsers::B2goGame.new(data).to_game
    rescue StandardError
      nil
    end
  end
end
