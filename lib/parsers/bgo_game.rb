module Parsers
  class BgoGame
    include Concerns::Parseable
    include Concerns::PlayerCountParser

    attr_reader :name,
                :rating,
                :weight,
                :year,
                :offer_count,
                :min_player_count,
                :max_player_count,
                :price,
                :playtime

    def initialize(data)
      parts = data.split("\n")

      case parts.size
      when 5
        @name, player_count, playtime, rating, weight = parts
      when 6
        @name, p2, player_count, playtime, rating, weight = parts
      when 9
        @name, p2, _, _, price, player_count, playtime, rating, weight = parts
      else
        raise ArgumentError, "Unexpected data format: #{parts.size} parts"
      end

      @price = price && price.delete_prefix("$").to_f
      @playtime = playtime.to_i
      @rating = rating.to_f
      @weight = weight.to_f
      @year, @offer_count = p2 ? p2.split("•").map(&:to_i) : [nil, nil]
      @min_player_count, @max_player_count = parse_player_count(player_count)
    end

    def to_game
      return if name.blank?

      Models::Game.new(
        name:,
        rating:,
        weight:,
        year:,
        offer_count:,
        min_player_count:,
        max_player_count:,
        price:,
        playtime:
      )
    end
  end
end
