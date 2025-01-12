module Downloaders
  class NameResolver < Struct.new(:bgo_games)
    def initialize(bgo_games)
      super
      @bgo_games_by_name = bgo_games.to_h { |game| [normalize(game.name), game] }
    end

    def find_bgo_game(bgg_game)
      @bgo_games_by_name[normalize(bgg_game.name)] || OpenStruct.new
    end

    private

    def normalize(str)
      str.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
    end
  end
end
