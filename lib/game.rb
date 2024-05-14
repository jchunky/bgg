require_relative "downloaders/replays_fetcher"

class Game
  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  def merge(other)
    Game.new(attributes.merge(other.attributes)) { |_, a, b| null?(a) ? b : a }
  end

  Categories::CATEGORIES.each do |category|
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

  def votes_per_year
    return 0 if years.zero?

    rating_count / years
  end

  def mechanics
    Categories::MECHANICS.keys.select(&method(:ranked_in_category?))
  end

  def families
    Categories::FAMILIES.keys.select(&method(:ranked_in_category?))
  end

  def replays
    # return 0
    @replays ||= Downloaders::ReplaysFetcher.new(objectid:).replays
  end

  def key
    href.scan(/\/(\d+)\//).first.first
  end

  def solo?
    solo_rank > 0 || one_player?
  end

  def one_player?
    one_player_rank > 0
  end

  def subdomains
    [
      ("ccg" if ccg?),
      ("child" if child?)
    ].compact
  end

  def ccg?
    ccg_rank > 0
  end

  def child?
    child_rank > 0
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
