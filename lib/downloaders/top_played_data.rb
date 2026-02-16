module Downloaders
  class TopPlayedData < FileBased
    def prefix = :top_played_data
    def listid = "top_played_data"

    def games
      @games ||= super
        .sort_by { -it.unique_users }
        .each.with_index(1) { |game, i| game.play_rank = i }
    end

    private

    def file_path = "./data/top_played_games.txt"
    def delimiter = "\n"
    def parser = Parsers::TopPlayedGame
  end
end
