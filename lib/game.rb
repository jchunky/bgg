require_relative "downloaders/replays_fetcher"

class Game
  DEFAULT_VALUES = {
    href: "",
    key: "",
    name: "",
    rating: 0.0,
    weight: 0.0,
  }

  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new do |hash, key|
      hash[key.to_sym] = DEFAULT_VALUES.fetch(key.to_sym, 0)
    end.merge(args)
  end

  def method_missing(method_name, *args)
    attribute_name = method_name.to_s.chomp("=").to_sym
    if method_name.to_s.end_with?("=")
      attributes[attribute_name] = args.first
    else
      attributes[attribute_name]
    end
  end

  def merge(other)
    Game.new(attributes.merge(other.attributes, &method(:merge_attr)))
  end

  def votes_per_year
    return 0 if year.zero?

    years = (Date.today.year + 1) - year
    years = years.clamp(1..)

    rating_count / years
  end

  def mechanics
    Categories::MECHANICS.keys.select { |m| read_rank_attribute(m) > 0 }
  end

  def families
    Categories::FAMILIES.keys.select { |f| read_rank_attribute(f) > 0 }
  end

  def replays
    @replays ||= Downloaders::ReplaysFetcher.new(href:).replays
  end

  Categories::CATEGORIES.each do |category|
    define_method("#{category}?") do
      read_rank_attribute(category) > 0
    end
  end

  private

  def merge_attr(_key, oldval, newval)
    oldval.present? && oldval != 0 ? oldval : newval
  end

  def read_rank_attribute(prefix)
    send("#{prefix}_rank")
  end
end
