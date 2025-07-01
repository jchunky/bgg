class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
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

  concerning :BestAtOnePlayer do
    def best_at_1_player?
      one_player_games.include?(name)
    end

    def one_player_games
      @one_player_games ||= File
        .read("./data/one_player_games.txt")
        .split("\n")
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

    private

    def bgo_data
      @bgo_data ||= Downloaders::BgoData.all.find_data(self)
    end
  end

  concerning :TopPlayedGames do
    delegate :play_rank, :unique_users, to: :top_played_data

    private

    def top_played_data
      @top_played_data ||= Downloaders::TopPlayedData.all.find_data(self)
    end
  end

  def key
    @key ||= href.scan(/\b\d+\b/).first.to_i rescue 0
  end
end
