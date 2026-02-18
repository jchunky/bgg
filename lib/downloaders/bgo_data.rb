# frozen_string_literal: true

module Downloaders
  class BgoData
    def prefix = :bgo_data
    def listid = "bgo_data"

    def games
      @games ||= File.read("./data/bgo.txt")
        .split("\n\n")
        .filter_map { |data| Parsers::BgoGame.parse(data) }
    end
  end
end
