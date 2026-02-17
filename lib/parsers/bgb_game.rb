module Parsers
  class BgbGame
    def self.parse(data)
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
    rescue
      nil
    end

    private_class_method def self.parse_player_count(player_count)
      return [nil, nil] if player_count.blank?

      if player_count.include?("-")
        player_count.split("-").map(&:to_i)
      else
        count = player_count.to_i
        [count, count]
      end
    end
  end
end
