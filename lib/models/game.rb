require_relative "../downloaders/replays_fetcher"

class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  concerning :Stats do
    def replays
      # return 0
      @replays ||= Downloaders::ReplaysFetcher.new(game: self).replays
    end

    def ghi
      # return 0
      @ghi ||= Downloaders::GhiFetcher.new(game: self).ghi
    end

    def ghi_per_price
      return unless price.to_f.positive? && ghi.to_f.positive?

      ghi.to_f / price.to_f
    end
  end

  concerning :Categories do
    def category_label
      @category_label ||= categories.sort.join(", ")
    end

    def categories
      @categories ||= Downloaders::CATEGORIES.map(&:prefix).select { send(:"#{_1}?") }
    end

    def subdomains
      @subdomains ||= Downloaders::SUBDOMAINS.map(&:prefix).select { send(:"#{_1}?") }.join(", ")
    end
  end

  concerning :Attributes do
    def method_missing(method_name, *args)
      attribute_name = method_name.to_s.chomp("=").chomp("?").to_sym
      if method_name.to_s.end_with?("=")
        attributes[attribute_name] = args.first
      elsif method_name.to_s.end_with?("?")
        !null?(send(:"#{attribute_name}_rank"))
      else
        attributes[attribute_name]
      end
    end

    def merge(other)
      Game.new(attributes.merge(other.attributes)) { |_, a, b| null?(a) ? b : a }
    end

    private

    def null?(value)
      !value || value.zero?
    end
  end

  concerning :BgoData do
    def player_count
      [min_player_count, max_player_count].compact.uniq.join("-")
    end

    def min_player_count
      bgo_data.min_player_count
    end

    def max_player_count
      bgo_data.max_player_count
    end

    def offer_count
      bgo_data.offer_count
    end

    def playtime
      bgo_data.playtime
    end

    def price
      bgo_data.price
    end

    private

    def bgo_data
      Downloaders::BgoData.find_bgo_data(self)
    end
  end

  def key
    @key ||= href.scan(/\b\d+\b/).first.to_i rescue 0
  end
end
