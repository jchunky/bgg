# frozen_string_literal: true

module Downloaders
  class B2goData
    BASE_URL = "https://backend.boardgame2go.com/api/v1/products/"
    LIMIT = 200

    def prefix = :b2go_data
    def listid = "b2go_data"

    def games
      @games ||= fetch_all_products
        .reject { it["purchaseOnly"] }
        .filter_map { build_game(it) }
    end

    private

    def fetch_all_products
      products = []
      offset = 0

      loop do
        data = fetch_page(offset)
        products.concat(data["docs"])
        offset += LIMIT
        break if offset >= data["total"]
      end

      products
    end

    def fetch_page(offset)
      url = "#{BASE_URL}?reservationDate=#{Date.tomorrow}&duration=7&offset=#{offset}&limit=#{LIMIT}"
      Utils::HttpFetcher.json(url, crawl_delay: 1) { it }
    end

    def build_game(product)
      name = product["name"]
      return if name.blank?

      players = product["players"] || {}

      Models::Game.new(
        name:,
        b2go: true,
        b2go_id: product["id"],
        b2go_price: best_rental_price(product),
        minplayers: players["from"].to_i,
        maxplayers: players["to"].to_i,
        maxplaytime: product["time"].to_i,
      )
    end

    def best_rental_price(product)
      rental = product.dig("prices", "rental")

      weekly = weekly_price(rental, "discountA") ||
               weekly_price(rental, "regular")

      (weekly.to_f / 100).round
    end

    def weekly_price(rental, tier)
      entry = rental[tier]
      return if entry.is_a?(Hash) && entry["active"] == false

      nights = entry.is_a?(Array) ? entry : entry["amountOfNights"]
      return unless nights.is_a?(Array)

      nights.find { it["nights"] == 7 }&.dig("price")
    end
  end
end
