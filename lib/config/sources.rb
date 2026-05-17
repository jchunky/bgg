# frozen_string_literal: true

module Config
  module Sources
    NO_EXPANSIONS = "nosubtypes[]=boardgameexpansion"
    SORTBY_RANK = "#{NO_EXPANSIONS}&sort=rank".freeze
    ONE_PLAYER_GAMES_1 = "#{SORTBY_RANK}&range[minplayers][max]=1&floatrange[avgweight][max]=2.5".freeze
    ONE_PLAYER_GAMES_2 = "#{SORTBY_RANK}&range[minplayers][max]=1&floatrange[avgweight][min]=2.5".freeze

    CATEGORIES = Config::Classifications::CATEGORIES.map { |c| ::Downloaders::GeekdoCategories.new(c) }
    SUBDOMAINS = Config::Classifications::SUBDOMAINS.map { |c| ::Downloaders::GeekdoCategories.new(c) }
    DOWNLOADERS = [
      ::Downloaders::B2goRentals.new,
      ::Downloaders::BgpPrices.new,
      *CATEGORIES,
      *SUBDOMAINS,
    ].freeze
  end
end
