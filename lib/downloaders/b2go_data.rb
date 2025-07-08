module Downloaders
  class B2goData
    def self.all =  @all ||= new

    def find_data(bgg_game)
      name_resolver.find_bgo_game(bgg_game)
    end

    private

    def name_resolver
      @name_resolve ||= NameResolver.new(games)
    end

    def games
      @games ||= File
        .read("./data/b2go.txt")
        .split("\n\n")
        .map { |data| build_game(data) }
        .reject { |game| game.name.blank? }
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
  end
end
