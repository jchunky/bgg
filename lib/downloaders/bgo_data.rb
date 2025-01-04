module Downloaders
  class BgoData
    class << self
      def find_bgo_data(bgg_game)
        bgo_games[normalize(bgg_game.name)] || OpenStruct.new
      end

      private

      def bgo_games
        @bgo_games ||= File
          .read("./bgo_data.txt")
          .split("\n\n")
          .map { |data| build_game(data) }
          .reject { |game| game.name.blank? }
          .to_h { |game| [normalize(game.name), game] }
      end

      def build_game(data)
        name, p2, _, _, price, player_count, playtime, rating, weight = data.split("\n")
        price = price.delete_prefix("$").to_f
        playtime = playtime.to_i
        rating = rating.to_f
        weight = weight.to_f
        year, offer_count = p2.split("•").map(&:to_i)
        if player_count.include?("-")
          min_player_count, max_player_count = player_count.split("-").map(&:to_i)
        else
          min_player_count = player_count.to_i
          max_player_count = player_count.to_i
        end
        OpenStruct.new(
          rating:,
          weight:,
          name:,
          year:,
          offer_count:,
          min_player_count:,
          max_player_count:,
          price:,
          playtime:
        )
      end

      def normalize(str)
        str.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
      end
    end
  end
end
