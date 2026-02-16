module Downloaders
  class TopPlayedData
    def prefix = :top_played_data
    def listid = "top_played_data"

    def games
      @games ||= parsed_games
        .sort_by { -it.unique_users }
        .each.with_index(1) { |game, i| game.play_rank = i }
    end

    private

    def parsed_games
      raw_records.filter_map { |data| parser.parse(data) }
    end

    def raw_records = File.read(file_path).split(delimiter)
    def file_path = "./data/top_played_games.txt"
    def delimiter = "\n"
    def parser = Parsers::TopPlayedGame
  end
end
