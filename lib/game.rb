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

  def play_rating
    unique_users * replays
  end

  def votes_per_year
    return 0 if years.zero?

    rating_count / years
  end

  def mechanics
    Categories::MECHANICS.keys.select(&method(:ranked_in_category?)).join(", ")
  end

  def families
    Categories::FAMILIES.keys.select(&method(:ranked_in_category?)).join(", ")
  end

  def subdomains
    Downloaders::SUBDOMAINS.map(&:prefix).select(&method(:ranked_in_category?)).join(", ")
  end

  def replays
    # return 0
    @replays ||= Downloaders::ReplaysFetcher.new(objectid:).replays
  end

  def key
    href.scan(/\/(\d+)\//).first.first
  end

  def player_count
    return if min_player_count.zero?

    [min_player_count, max_player_count].compact.uniq.join("-")
  end

  def min_player_count
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

  def own?
    OwnedGames.include?(self)
  end

  private

  def objectid
    href.scan(/\b\d+\b/).first.to_i
  end

  def years
    result = (Date.today.year + 1) - year
    result.clamp(1..)
  end

  def null?(value)
    !value || value.zero?
  end

  def ranked_in_category?(category)
    category_rank(category) > 0
  end

  def category_rank(category)
    send("#{category}_rank")
  end
end
