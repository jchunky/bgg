module Downloaders
  class TopPlayedData < Base
    def prefix = :top_played_data
    def listid = "top_played_data"

    def games
      @games ||= File
        .read("./data/top_played_games.txt")
        .split("\n")
        .filter_map { |data| Parsers::TopPlayedGame.parse(data) }
        .sort_by { -_1.unique_users }
        .each.with_index(1) { |game, i| game.play_rank = i }
    end
  end
end
