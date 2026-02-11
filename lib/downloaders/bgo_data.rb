module Downloaders
  class BgoData < Base
    def prefix = :bgo_data
    def listid = "bgo_data"

    def games
      @games ||= File
        .read("./data/bgo.txt")
        .split("\n\n")
        .filter_map { |data| Parsers::BgoGame.parse(data) }
    end
  end
end
