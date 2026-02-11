module Parsers
  class B2goGame
    attr_reader :name, :price

    def self.parse(data)
      new(data).to_game
    rescue StandardError
      nil
    end

    def initialize(data)
      name, @details, price_line, = data

      @name = name.split("(").first.strip
      @price = price_line.split.last.delete_prefix("$").to_f.round
    end

    def to_game
      return if name.nil? || name.empty?
      return if purchase_only?

      Models::Game.new(
        name:,
        b2go: true,
        b2go_price: price
      )
    end

    private

    def purchase_only?
      @details == "Purchase Only"
    end
  end
end
