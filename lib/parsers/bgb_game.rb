module Parsers
  class BgbGame
    include Concerns::PlayerCountParser

    attr_reader :name,
                :min_player_count,
                :max_player_count,
                :playtime,
                :rating,
                :weight,
                :preorder,
                :price

    def self.parse(data)
      new(data).to_game
    rescue StandardError
      nil
    end

    def initialize(data)
      _, _, @name, _, player_count, playtime, rating, weight, preorder, price = data.split("\n")

      @preorder = preorder.include?("*PRE-ORDER*")
      @price = price.delete_prefix("$").to_f
      @playtime = playtime.to_i
      @rating = rating.to_f
      @weight = weight.to_f
      @min_player_count, @max_player_count = parse_player_count(player_count)
    end

    def to_game
      Models::Game.new(
        name:,
        rating:,
        weight:,
        preorder:,
        bgb: true,
        min_player_count:,
        max_player_count:,
        bgb_price: price,
        playtime:
      )
    end

  end
end
