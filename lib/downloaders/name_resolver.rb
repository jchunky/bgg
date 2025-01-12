module Downloaders
  class NameResolver
    attr_reader :bgo_games, :bgo_games_by_name

    def initialize(bgo_games)
      @bgo_games = bgo_games
      @bgo_games_by_name = bgo_games.to_h { |game| [normalize(game.name), game] }
    end

    def find_bgo_game(bgg_game)
      bgo_games_by_name[normalize(bgg_game.name)] || OpenStruct.new
    end

    private

    def normalize(str)
      str.to_s.downcase.gsub(/[^\w\s]/, "").squish
    end
  end
end
