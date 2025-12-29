module Downloaders
  class B2goData
    def prefix = :b2go_data
    def listid = "b2go_data"

    def games
      @games ||= File
        .read("./data/b2go.txt")
        .split("\n")
        .each_slice(4)
        .map { |data| build_game(data) }
        .reject { |game| game.name.blank? }
    end

    private

    def build_game(data)
      name, _, price, _ = data
      price = price.split(" ").last.delete_prefix("$").to_f
      name = name.split("(").first.strip

      Game.new(
        name:,
        b2go: true,
        b2go_price: price,
      )
    end
  end
end
