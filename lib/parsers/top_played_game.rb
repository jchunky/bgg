module Parsers
  class TopPlayedGame
    include Concerns::Parseable

    attr_reader :name, :play_count, :unique_users

    PATTERN = /(.*)\s+(\d+)\s+(\d+)$/

    def initialize(data)
      match = data.match(PATTERN)
      raise ArgumentError, "Invalid format: #{data}" unless match

      @name = match[1].strip
      @play_count = match[2].to_i
      @unique_users = match[3].to_i
    end

    def to_game
      return if name.nil? || name.empty?

      Models::Game.new(
        name:,
        play_count:,
        unique_users:
      )
    end
  end
end
