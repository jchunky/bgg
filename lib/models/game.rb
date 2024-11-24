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

    def max_playtime
      @max_playtime ||= (15..360).step(15).find { |time| send(:"playtime_#{time}?") } || 0
    end
  end

  concerning :PlayerCount do
    def player_count
      return @player_count if defined?(@player_count)

      @player_count = calculate_player_count
    end

    def min_player_count
      @min_player_count ||= (1..12).find { |count| send(:"player_#{count}?") } || 0
    end

    def max_player_count
      @max_player_count ||= (1..12).to_a.reverse.find { |count| send(:"player_#{count}?") } || 0
    end

    private

    def calculate_player_count
      return nil if min_player_count.zero?

      [min_player_count, max_player_count].compact.uniq.join("-")
    end
  end

  concerning :Categories do
    def category_label
      @category_label ||= mechanics.sort.join(", ")
    end

    def mechanics
      @mechanics ||= Downloaders::MECHANICS.map(&:prefix).select { send(:"#{_1}?") }
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

  def key
    @key ||= href.scan(/\b\d+\b/).first.to_i rescue 0
  end
end
