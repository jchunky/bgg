# frozen_string_literal: true

module Parsers
  class B2goGame
    def self.parse(data)
      name_raw, details, price_line, = data

      name = name_raw.split("(").first.strip
      return if name.blank?
      return if details == "Purchase Only"

      price = price_line.split.last.delete_prefix("$").to_f.round

      Models::Game.new(
        name:,
        b2go: true,
        b2go_price: price,
      )
    rescue StandardError
      nil
    end
  end
end
