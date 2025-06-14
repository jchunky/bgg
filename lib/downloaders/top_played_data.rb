module Downloaders
  class TopPlayedData
    def self.all =  @all ||= new

    def find_data(bgg_game)
      games.find { _1.name == bgg_game.name } || OpenStruct.new
    end

    private

    def games
      @games ||= File
        .read("./data/top_played_games.csv")
        .split("\n")
        .map { build_game(_1) }
        .sort_by { -_1.unique_users }
        .each.with_index(1) { |game, i| game.play_rank = i }
    end

    def build_game(data)
      name, play_count, unique_users = data.split(",")
      play_count = play_count.to_i
      unique_users = unique_users.to_i

      OpenStruct.new(
        name:,
        play_count:,
        unique_users:,
      )
    end
  end
end
