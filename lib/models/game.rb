require_relative "../downloaders/replays_fetcher"

class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  concerning :Stats do
    def replays
      return 0
      @replays ||= Downloaders::ReplaysFetcher.new(game: self).replays
    end

    def ghi
      return 0
      @ghi ||= Downloaders::GhiFetcher.new(game: self).ghi
    end

    def cost_per_play
      return unless price.to_f.positive? && replays.to_f.positive?

      price / replays.to_f
    end
  end

  concerning :Categories do
    def category_label
      @category_label ||= categories.sort.join(", ")
    end

    def categories
      @categories ||= begin
        result = Downloaders::CATEGORIES.map(&:prefix).select { send(:"#{_1}?") }
        result << :bgb if bgb?
        result << :games401 if games401?
        result << :gameshack if gameshack?
        result
      end
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
    delegate :min_player_count, :max_player_count, :offer_count, :playtime, :price, to: :bgo_data

    def player_count
      [min_player_count, max_player_count].compact.uniq.join("-")
    end

    def bgb?
      Downloaders::BgoStoreData.bgb.find_data(self).price
    end

    def games401?
      Downloaders::BgoStoreData.games401.find_data(self).price
    end

    def gameshack?
      Downloaders::BgoStoreData.gameshack.find_data(self).price
    end

    private

    def bgo_data
      @bgo_data ||= Downloaders::BgoData.all.find_data(self)
    end
  end

  def key
    @key ||= href.scan(/\b\d+\b/).first.to_i rescue 0
  end
end
