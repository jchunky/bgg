module Downloaders
  class BgoData
    def prefix = :bgo_data
    def listid = "bgo_data"

    def games
      @games ||= raw_records.filter_map { |data| parser.parse(data) }
    end

    private

    def raw_records = File.read(file_path).split(delimiter)
    def file_path = "./data/bgo.txt"
    def delimiter = "\n\n"
    def parser = Parsers::BgoGame
  end
end
