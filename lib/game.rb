require_relative "downloaders/replays_fetcher"

class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  def merge(other)
    Game.new(attributes.merge(other.attributes)) { |_, a, b| null?(a) ? b : a }
  end

  Downloaders::DOWNLOADERS.map(&:prefix).each do |category|
    define_method("#{category}?") do
      ranked_in_category?(category)
    end
  end

  def method_missing(method_name, *args)
    attribute_name = method_name.to_s.chomp("=").to_sym
    if method_name.to_s.end_with?("=")
      attributes[attribute_name] = args.first
    else
      attributes[attribute_name]
    end
  end

  def mechanics
    @mechanics ||= Categories::MECHANICS.keys.select(&method(:ranked_in_category?)).join(", ")
  end

  def families
    @families ||= Categories::FAMILIES.keys.select(&method(:ranked_in_category?)).join(", ")
  end

  def subdomains
    @subdomains ||= Downloaders::SUBDOMAINS.map(&:prefix).select(&method(:ranked_in_category?)).join(", ")
  end

  def replays
    # return 0
    @replays ||= Downloaders::ReplaysFetcher.new(objectid: key).replays
  end

  def key
    @key ||= href.scan(/\b\d+\b/).first.to_i
  end

  def player_count
    return @player_count if defined?(@player_count)

    @player_count =
      if min_player_count.zero?
        nil
      else
        [min_player_count, max_player_count].compact.uniq.join("-")
      end
  end

  def own?
    return @own if defined?(@own)

    @own = OwnedGames.include?(self)
  end

  private

  def min_player_count
    @min_player_count ||=
      case
      when player_1? then 1
      when player_2? then 2
      when player_3? then 3
      when player_4? then 4
      when player_5? then 5
      when player_6? then 6
      when player_7? then 7
      when player_8? then 8
      when player_9? then 9
      when player_10? then 10
      when player_11? then 11
      when player_12? then 12
      else 0
      end
  end

  def max_player_count
    @max_player_count ||=
      case
      when player_12? then 12
      when player_11? then 11
      when player_10? then 10
      when player_9? then 9
      when player_8? then 8
      when player_7? then 7
      when player_6? then 6
      when player_5? then 5
      when player_4? then 4
      when player_3? then 3
      when player_2? then 2
      when player_1? then 1
      else 0
      end
  end

  def ranked_in_category?(category)
    category_rank(category) > 0
  end

  def category_rank(category)
    send("#{category}_rank")
  end

  def null?(value)
    !value || value.zero?
  end
end
