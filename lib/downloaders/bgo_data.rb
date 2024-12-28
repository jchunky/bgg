module Downloaders
  class BgoData
    class << self
      def bgg_games=(bgg_games)
        @bgg_games = bgg_games
        process_matches
      end

      def price_for(bgg_game)
        level, bgo_game = find_bgo_match(bgg_game)
        return unless bgo_game

        # p [level, bgg_game.rank, bgg_game.name, bgo_game.name] if level >= 2

        bgo_game.the_price
      end

      def bgg_games
        @bgg_games
      end

      private

      def process_matches
        @lookup = {}
        bgo_next_pool = bgo_games.dup
        bgg_pool = bgg_games.dup

        match_functions = [
          ->(bgo_game, bgg_game) { bgo_game.name == bgg_game.name },
          ->(bgo_game, bgg_game) { bgo_game.name.downcase == bgg_game.name.downcase },
          ->(bgo_game, bgg_game) { normalize(bgo_game.name) == normalize(bgg_game.name.downcase) },
        ]

        match_functions.each.with_index(1) do |match_function, level|
          bgo_pool = bgo_next_pool
          bgo_next_pool = []
          bgo_pool.each do |bgo_game|
            bgg_game = bgg_pool.find { |bgg_game| match_function.call(bgo_game, bgg_game) }
            if bgg_game
              @lookup[bgg_game.name] = [level, bgo_game]
              bgg_pool.delete(bgg_game)
            else
              bgo_next_pool << bgo_game
            end
          end
        end

        # p "BGO games without matches"
        # pp bgo_next_pool.map(&:name)
        # p "BGG games without matches"
        # pp bgg_pool.map(&:name)
      end

      def find_bgo_match(bgg_game)
        @lookup[bgg_game.name]
      end

      def bgo_games
        @bgo_games ||= File
          .read("./bgo_data.txt")
          .split("\n\n")
          .map { |data| build_game(data) }
          .reject { |game| game.name.blank? }
      end

      def normalize(str)
        str.to_s.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, ' ').strip
      end

      def build_game(data)
        name, p2, _, price, p5, play_time, rating, weight = data.split("\n")
        price = price.delete_prefix("$").to_f
        rating = rating.to_f
        weight = weight.to_f
        year, offer_count = p2.split("•").map(&:to_i)
        if p5.include?("-")
          min_player_count, max_player_count = p5.split("-").map(&:to_i)
        else
          min_player_count = p5.to_i
          max_player_count = p5.to_i
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
