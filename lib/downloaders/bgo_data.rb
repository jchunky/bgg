module Downloaders
  class BgoData
    class << self
      NAME_TRANSFORMS = {
        "Zombicide (2nd Edition)" => "Zombicide: 2nd Edition",
      }

      def price_for(game)
        bgo_game = games.find { |g| normalize_name(g.name.to_s).downcase == game.name.downcase }
        return unless bgo_game

        bgo_game.the_price
      end

      def method_name

      end

      def games
        @games ||= File
          .read("./bgo_data.txt")
          .split("\n\n")
          .map { |data| build_game(data) }
      end

      private

      def normalize_name(name)
        NAME_TRANSFORMS.fetch(name, name)
      end

      def build_game(data)
        p1, _, p3, p4, play_time, rating, weight = data.split("\n")
        price = p3.split("$").last.to_f
        rating = rating.to_f
        weight = weight.to_f
        name, year, offer_count = p1.scan(/(.*)(\d{4}) • (\d+) offer/).first
        year = year.to_i
        offer_count = offer_count.to_i
        if p4.include?(" - ")
          min_player_count, max_player_count = p4.split(" - ").map(&:to_i)
        else
          min_player_count = p4.to_i
          max_player_count = p4.to_i
        end
        Game.new(
          rating:,
          weight:,
          name:,
          year:,
          offer_count:,
          min_player_count:,
          max_player_count:,
          the_price: price,
        )
      end
    end
  end
end
