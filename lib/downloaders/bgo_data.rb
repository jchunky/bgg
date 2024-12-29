module Downloaders
  class BgoData
    class << self
      attr_reader :bgg_games

      def bgg_games=(bgg_games)
        @bgg_games = bgg_games
        process_matches
      end

      def find_bgo_data(bgg_game)
        level, bgo_game = @lookup[bgg_game.name]
        return OpenStruct.new unless bgo_game

        # p [level, bgg_game.rank, bgg_game.name, bgo_game.name] if level >= 2

        return bgo_game
      end

      private

      def process_matches
        @lookup = {}
        bgo_next_pool = bgo_games.dup
        bgg_pool = bgg_games.dup

        match_functions = [
          ->(bgo_game, bgg_game) { bgo_game.name == bgg_game.name },
          ->(bgo_game, bgg_game) { bgo_game.name.downcase == bgg_game.name.downcase },
          ->(bgo_game, bgg_game) { normalize(bgo_game.name) == normalize(bgg_game.name) },
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
        name, p2, _, _, price, p6, playtime, rating, weight = data.split("\n")
        price = price.delete_prefix("$").to_f
        playtime = playtime.to_i
        rating = rating.to_f
        weight = weight.to_f
        year, offer_count = p2.split("•").map(&:to_i)
        if p6.include?("-")
          min_player_count, max_player_count = p6.split("-").map(&:to_i)
        else
          min_player_count = p6.to_i
          max_player_count = p6.to_i
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
          playtime:,
        )
      end
    end
  end
end
