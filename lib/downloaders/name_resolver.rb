module Downloaders
  class NameResolver
    attr_reader :bgg_games, :bgo_games, :bgo_games_by_name

    def self.assign_bgg_games(bgg_games)
      @bgg_games = bgg_games
    end

    def self.bgg_games
      @bgg_games
    end

    def initialize(bgo_games)
      @bgo_games = bgo_games
      @bgg_games = self.class.bgg_games.dup
      @bgo_games_by_name = bgo_games.to_h { |game| [normalize(game.name), game] }
    end

    def find_bgo_game(bgg_game)
      bgo_games_by_name[normalize(bgg_game.name)] || OpenStruct.new
    end

    private

    def normalize(str)
      str.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
    end
  end
end
