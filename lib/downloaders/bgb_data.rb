module Downloaders
  class BgbData < Base
    def prefix = :bgb_data
    def listid = "bgb_data"

    def games
      @games ||= File
        .read("./data/bgb.txt")
        .split("\n\n")
        .filter_map { |data| Parsers::BgbGame.parse(data) }
        .reject { |game| game.name.blank? }
    end
  end
end
