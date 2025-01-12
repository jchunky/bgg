module Downloaders
  class NameResolver
    attr_reader :bgo_games

    def initialize(bgo_games)
      @bgo_games = bgo_games.to_h { |game| [normalize(game.name), game] }
    end

    def find_bgo_game(bgg_game)
      bgo_games[normalize(bgg_game.name)] || OpenStruct.new
    end

    private

    def normalize(str)
      str.to_s.downcase.gsub(/[^\w\s]/, "").squish
    end
  end
end
