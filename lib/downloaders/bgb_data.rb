module Downloaders
  class BgbData
    def prefix = :bgb_data
    def listid = "bgb_data"

    def games
      @games ||= File
        .read("./data/bgb.txt")
        .split("\n\n")
        .map { |data| build_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

    def build_game(data)
      _, _, name, _, player_count, playtime, rating, weight, preorder, price = data.split("\n")

      preorder = preorder.include?("*PRE-ORDER*")
      price = price.delete_prefix("$").to_f
      playtime = playtime.to_i
      rating = rating.to_f
      weight = weight.to_f
      if player_count.include?("-")
        min_player_count, max_player_count = player_count.split("-").map(&:to_i)
      else
        min_player_count = player_count.to_i
        max_player_count = player_count.to_i
      end

      Game.new(
        rating:,
        weight:,
        preorder:,
        bgb: true,
        name:,
        min_player_count:,
        max_player_count:,
        bgb_price: price,
        playtime:
      )
    rescue StandardError
      OpenStruct.new
    end
  end
end
