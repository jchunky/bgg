module Downloaders
  class BgoStoreData
    attr_reader :store_name, :name_resolver

    def self.bgb =  @bgb ||= new(:bgb)
    def self.games401 =  @games401 ||= new(:games401)
    def self.gameshack =  @gameshack ||= new(:gameshack)
    def self.mission =  @mission ||= new(:mission)

    def initialize(store_name)
      @store_name = store_name
      @name_resolver = NameResolver.new(games)
    end

    def find_data(bgg_game)
      name_resolver.find_bgo_game(bgg_game)
    end

    def games
      @games ||= File
        .read("./data/#{store_name}.txt")
        .split("\n")
        .each_slice(13)
        .map { |data| build_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

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
