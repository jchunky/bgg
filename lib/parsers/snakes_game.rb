# frozen_string_literal: true

module Parsers
  class SnakesGame
    def self.parse(game_data)
      name, *, loc = game_data
      return if name.blank?

      location = loc.scan(/\b\d+\w\b/).first
      location ||= "New Arrivals" if loc.downcase.include?("new arrivals")
      location ||= "Staff Picks" if loc.downcase.include?("staff picks")

      Models::Game.new(
        name:,
        snakes_location: location,
        snakes: !location.nil?,
      )
    rescue StandardError
      nil
    end
  end
end
