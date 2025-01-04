module Downloaders
  class BgbData
    class << self
      def find_bgb_data(bgg_game)
        bgb_games[normalize(bgg_game.name)] || OpenStruct.new
      end

      private

      def bgb_games
        @bgb_games ||= File
          .read("./bgb_data.txt")
          .split("\n")
          .each_slice(13)
          .map { |data| build_game(data) }
          .reject { |game| game.name.blank? }
          .to_h { |game| [normalize(game.name), game] }
      end

      def build_game(data)
        name, _, player_count, playtime, rating, weight, _, price, _, _, _, in_stock = data
        price = price.delete_prefix("$").to_f
        playtime = playtime.to_i
        rating = rating.to_f
        weight = weight.to_f
        in_stock = in_stock == "In stock"
        if player_count.include?("-")
          min_player_count, max_player_count = player_count.split("-").map(&:to_i)
        else
          min_player_count = player_count.to_i
          max_player_count = player_count.to_i
        end
        return OpenStruct.new unless in_stock

        OpenStruct.new(
          rating:,
          weight:,
          name:,
          min_player_count:,
          max_player_count:,
          price:,
          playtime:,
          in_stock:
        )
      end

      def normalize(str)
        str.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
      end
    end
  end
end
