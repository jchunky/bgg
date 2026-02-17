module Parsers
  class TopPlayedGame
    PATTERN = /(.*)\s+(\d+)\s+(\d+)$/

    def self.parse(data)
      match = data.match(PATTERN)
      return unless match

      name = match[1].strip
      return if name.blank?

      Models::Game.new(
        name:,
        play_count: match[2].to_i,
        unique_users: match[3].to_i
      )
    rescue
      nil
    end
  end
end
