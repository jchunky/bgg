class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  def soloable?
    max_player_count == 1 || (coop? && min_player_count == 1)
  end

  def crowdfunded?
    kickstarter? || gamefound? || backerkit?
  end

  def escaperoom?
    [
      "EXIT",
      "Deckscape",
      "Rory's Story Cubes",
      "Unlock!",
    ].any? { name.start_with?("#{_1}:") }
  end

  concerning :Categories do
    def category_label
      @category_label ||= begin
        result = categories
        result << :b2go if b2go?
        result << :bgb if bgb?
        result << :preorder if preorder?
        result.sort.join(", ")
      end
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

  concerning :GameData do
    def b2go? = (b2go == true)
    def bgb? = (bgb == true && !preorder?)
    def play_rank? = (play_rank > 0)
    def preorder? = (preorder == true)
    def player_count = ([min_player_count, max_player_count].compact.uniq.join("-"))
  end

  def key
    @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
  end
end
