require_relative "downloaders/replays_fetcher"

class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  concerning :Stats do
    def replays
      # return 0
      @replays ||= Downloaders::ReplaysFetcher.new(objectid: key).replays
    end

    def min_age
      @min_age ||= (2..18).find { |age| send("age_#{age}?") } || 0
    end

    def max_playtime
      @max_playtime ||= (15..360).step(15).find { |time| send("playtime_#{time}?") == true } || 0
    end
  end

  concerning :Ownership do
    def ownership
      case
      when own? then "own"
      when played? then "played"
      when online? then "online"
      end
    end

    def own?
      return @own if defined?(@own)

      @own = OwnedGames.include?(self)
    end

    def played?
      return @played if defined?(@played)

      @played = PlayedGames.include?(self)
    end

    def online?
      return @online if defined?(@online)

      @online = OnlineGames.include?(self)
    end
  end

  concerning :PlayerCount do
    def player_count
      return @player_count if defined?(@player_count)

      @player_count =
        if min_player_count.zero?
          nil
        else
          [min_player_count, max_player_count].compact.uniq.join("-")
        end
    end

    def min_player_count
      @min_player_count ||= (1..12).find { |count| send("player_#{count}?") == true } || 0
    end

    def max_player_count
      @max_player_count ||= (1..12).to_a.reverse.find { |count| send("player_#{count}?") == true } || 0
    end
  end

  concerning :Categories do
    included do
      ::Downloaders::DOWNLOADERS.map(&:prefix).each do |category|
        define_method("#{category}?") do
          ranked_in_category?(category)
        end
      end
    end

    def categories
      @categories ||= Downloaders::CATEGORIES.map(&:prefix).select(&method(:ranked_in_category?)).join(", ")
    end

    def mechanics
      @mechanics ||= Downloaders::MECHANICS.map(&:prefix).select(&method(:ranked_in_category?)).join(", ")
    end

    def families
      @families ||= Downloaders::FAMILIES.map(&:prefix).select(&method(:ranked_in_category?)).join(", ")
    end

    def subdomains
      @subdomains ||= Downloaders::SUBDOMAINS.map(&:prefix).select(&method(:ranked_in_category?)).join(", ")
    end

    private

    def ranked_in_category?(category)
      category_rank(category) > 0
    end

    def category_rank(category)
      send("#{category}_rank")
    end
  end

  concerning :Attributes do
    def method_missing(method_name, *args)
      attribute_name = method_name.to_s.chomp("=").to_sym
      if method_name.to_s.end_with?("=")
        attributes[attribute_name] = args.first
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

  def key
    @key ||= href.scan(/\b\d+\b/).first.to_i
  end
end
