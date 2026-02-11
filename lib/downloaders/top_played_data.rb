module Downloaders
  class TopPlayedData < Base
    def prefix = :top_played_data
    def listid = "top_played_data"

    def games
      @games ||= File
        .read("./data/top_played_games.txt")
        .split("\n")
        .map { build_game(_1) }
        .compact
        .sort_by { -_1.unique_users }
        .each.with_index(1) { |game, i| game.play_rank = i }
    end

    private

    def build_game(data)
      return unless data =~ /(.*)\s+(\d+)\s+(\d+)$/

      Models::Game.new(
        name: $1.strip,
        play_count: $2.to_i,
        unique_users: $3.to_i,
      )
    end
  end
end
