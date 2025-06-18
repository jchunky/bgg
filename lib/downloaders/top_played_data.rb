module Downloaders
  class TopPlayedData
    def self.all =  @all ||= new

    def find_data(bgg_game)
      games.find { _1.name == bgg_game.name } || OpenStruct.new
    end

    private

    def games
      @games ||= File
        .read("./data/top_played_games.txt")
        .split("\n")
        .map { build_game(_1) }
        .compact
        .sort_by { -_1.unique_users }
        .each.with_index(1) { |game, i| game.play_rank = i }
    end

    def build_game(data)
      return unless data =~ /(.*)\s+(\d+)\s+(\d+)$/

      OpenStruct.new(
        name: $1.strip,
        play_count: $2.to_i,
        unique_users: $3.to_i,
      )
    end
  end
end
