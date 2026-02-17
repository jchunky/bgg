module Parsers
  class TopPlayedGame
    PATTERN = /(.*)\s+(\d+)\s+(\d+)$/

    attr_reader :name, :play_count, :unique_users

    def self.parse(data) = new(data).to_game rescue nil

    def initialize(data)
      match = data.match(PATTERN)
      raise ArgumentError, "Invalid format: #{data}" unless match

      @name = match[1].strip
      @play_count = match[2].to_i
      @unique_users = match[3].to_i
    end

    def to_game
      return if name.blank?

      Models::Game.new(
        name:,
        play_count:,
        unique_users:
      )
    end
  end
end
