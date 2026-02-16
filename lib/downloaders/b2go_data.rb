module Downloaders
  class B2goData
    def prefix = :b2go_data
    def listid = "b2go_data"

    def games
      @games ||= raw_records.filter_map { |data| parser.parse(data) }
    end

    private

    def raw_records = File.read(file_path).split(delimiter).each_slice(4).to_a
    def file_path = "./data/b2go.txt"
    def delimiter = "\n"
    def parser = Parsers::B2goGame
  end
end
