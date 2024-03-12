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
    return 0 if year.zero?

    years = (Date.today.year + 1) - year
    years = years.clamp(1..)

    rating_count / years
  end

  def mechanics
    Categories::MECHANICS.keys.select(&method(:ranked_in_category?))
  end

  def families
    Categories::FAMILIES.keys.select(&method(:ranked_in_category?))
  end

  def replays
    @replays ||= Downloaders::ReplaysFetcher.new(href:).replays
  end

  def key
    href
  end

  private

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
