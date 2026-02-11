module Parsers
  class SnakesGame
    attr_reader :name, :location

    def initialize(game_data)
      @name, *, location = game_data
      @location = normalize_location(location)
    end

    def to_game
      Models::Game.new(
        name:,
        snakes_location: location,
        snakes: !!location
      )
    end

    private

    def normalize_location(location)
      match = location.scan(/\b\d+\w\b/).first
      return match if match

      return "New Arrivals" if location.downcase.include?("new arrivals")
      return "Staff Picks" if location.downcase.include?("staff picks")

      nil
    end
  end
end
