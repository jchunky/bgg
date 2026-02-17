module Parsers
  class BgbGame
    class << self
      include Concerns::PlayerCountParser

      def parse(data)
        _, _, name, _, player_count, playtime, rating, weight, preorder, price = data.split("\n")
        return if name.blank?

        min_player_count, max_player_count = parse_player_count(player_count)

        Models::Game.new(
          name:,
          rating: rating.to_f,
          weight: weight.to_f,
          preorder: preorder.include?("*PRE-ORDER*"),
          bgb: true,
          min_player_count:,
          max_player_count:,
          bgb_price: price.delete_prefix("$").to_f,
          playtime: playtime.to_i
        )
      rescue StandardError
        nil
      end

    end
  end
end
