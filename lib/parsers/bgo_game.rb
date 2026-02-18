# frozen_string_literal: true

module Parsers
  class BgoGame
    class << self
      include Concerns::PlayerCountParser

      def parse(data)
        parts = data.split("\n")

        case parts.size
        when 5
          name, player_count, playtime, rating, weight = parts
        when 6
          name, p2, player_count, playtime, rating, weight = parts
        when 9
          name, p2, _, _, price, player_count, playtime, rating, weight = parts
        else
          return nil
        end

        return if name.blank?

        price &&= price.delete_prefix("$").to_f
        year, offer_count = p2 ? p2.split("•").map(&:to_i) : [nil, nil]
        min_player_count, max_player_count = parse_player_count(player_count)

        Models::Game.new(
          name:,
          rating: rating.to_f,
          weight: weight.to_f,
          year:,
          offer_count:,
          min_player_count:,
          max_player_count:,
          price:,
          playtime: playtime.to_i,
        )
      rescue StandardError
        nil
      end
    end
  end
end
