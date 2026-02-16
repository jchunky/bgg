module Downloaders
  class BgbData
    def prefix = :bgb_data
    def listid = "bgb_data"

    def games
      @games ||= raw_records.filter_map { |data| parser.parse(data) }
    end

    private

    def raw_records = File.read(file_path).split(delimiter)
    def file_path = "./data/bgb.txt"
    def delimiter = "\n\n"
    def parser = Parsers::BgbGame
  end
end
