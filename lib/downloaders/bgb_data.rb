module Downloaders
  class BgbData
    class << self
      attr_reader :bgg_games

      def bgg_games=(bgg_games)
        @bgg_games = bgg_games
        process_matches
      end

      def find_bgb_data(bgg_game)
        level, bgb_game = @lookup[bgg_game.name]
        return OpenStruct.new unless bgb_game

        # p [level, bgg_game.rank, bgg_game.name, bgb_game.name] if level >= 2

        bgb_game
      end

      private

      def process_matches
        @lookup = {}
        bgb_next_pool = bgb_games.dup
        bgg_pool = bgg_games.dup

        match_functions = [
          ->(bgb_game, bgg_game) { bgb_game.name == bgg_game.name },
          ->(bgb_game, bgg_game) { bgb_game.name.downcase == bgg_game.name.downcase },
          ->(bgb_game, bgg_game) { normalize(bgb_game.name) == normalize(bgg_game.name) },
        ]

        match_functions.each.with_index(1) do |match_function, level|
          bgb_pool = bgb_next_pool
          bgb_next_pool = []
          bgb_pool.each do |bgb_game|
            bgg_game = bgg_pool.find { |bgg_game| match_function.call(bgb_game, bgg_game) }
            if bgg_game
              @lookup[bgg_game.name] = [level, bgb_game]
              bgg_pool.delete(bgg_game)
            else
              bgb_next_pool << bgb_game
            end
          end
        end

        # p "bgb games without matches"
        # pp bgb_next_pool.map(&:name)
        # p "BGG games without matches"
        # pp bgg_pool.map(&:name)
      end

      def bgb_games
        @bgb_games ||= File
          .read("./bgb_data.txt")
          .split("\n")
          .each_slice(13)
          .map { |data| build_game(data) }
          .reject { |game| game.name.blank? }
      end

      def normalize(str)
        str.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
      end

      # Scrabble
      # Scrabble
      # 2 - 4
      # 90
      # 6.3
      # 2.1
      # Scrabble Deluxe Giant
      # $219.95

      # +817%

      # In stock
      # Go to Store

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
    end
  end
end
