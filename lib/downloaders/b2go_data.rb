module Downloaders
  class B2goData
    def prefix = :b2go_data
    def listid = "b2go_data"

    def games
      @games ||= File.read("./data/b2go.txt")
        .split("\n")
        .each_slice(4)
        .to_a
        .filter_map { |data| Parsers::B2goGame.parse(data) }
    end
  end
end
