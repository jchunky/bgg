module Downloaders
  class BgoData < Base
    def prefix = :bgo_data
    def listid = "bgo_data"

    def games
      @games ||= File
        .read("./data/bgo.txt")
        .split("\n\n")
        .map { |data| build_game(data) }
        .compact
        .reject { |game| game.name.blank? }
    end

    private

    def build_game(data)
      parts = data.split("\n")

      case parts.size
      when 5
        name, player_count, playtime, rating, weight = parts
      when 6
        name, p2, player_count, playtime, rating, weight = parts
      when 9
        name, p2, _, _, price, player_count, playtime, rating, weight = parts
      else
        p parts.size
        p data
      end

      price = price && price.delete_prefix("$").to_f
      playtime = playtime.to_i
      rating = rating.to_f
      weight = weight.to_f
      year, offer_count = p2 ? p2.split("•").map(&:to_i) : nil
      if player_count.include?("-")
        min_player_count, max_player_count = player_count.split("-").map(&:to_i)
      else
        min_player_count = player_count.to_i
        max_player_count = player_count.to_i
      end

      Models::Game.new(
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
    rescue StandardError
      nil
    end
  end
end
