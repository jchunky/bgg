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
  end

  concerning :BgbData do
    def bgb?
      bgb
    end

    def preorder?
      preorder
    end
  end

  def key
    @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
  end
end
