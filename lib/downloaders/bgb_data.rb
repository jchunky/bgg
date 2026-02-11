module Downloaders
  class BgbData < Base
    def prefix = :bgb_data
    def listid = "bgb_data"

    def games
      @games ||= File
        .read("./data/bgb.txt")
        .split("\n\n")
        .filter_map { |data| parse_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

    def parse_game(data)
      Parsers::BgbGame.new(data).to_game
    rescue StandardError
      nil
    end
  end
end
