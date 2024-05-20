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

  def min_age
    @min_age ||= (1..24).find { |age| send("age_#{age}?") } || 0
  end

  def max_playtime_label
    @max_playtime_label ||=
      case max_playtime
      when 15 then "15 minutes"
      when 30 then "30 minutes"
      when 45 then "45 minutes"
      when 60 then "60 minutes"
      when 90 then "1.5 hours"
      when 120 then "2 hours"
      when 150 then "1.5 hours"
      when 180 then "3 hours"
      when 210 then "3.5 hours"
      when 240 then "4 hours"
      when 300 then "5 hours"
      when 360 then "6+ hours"
      else ""
      end
  end

  def max_playtime
    @max_playtime ||=
      case
      when playtime_15? then 15
      when playtime_30? then 30
      when playtime_45? then 45
      when playtime_60? then 60
      when playtime_90? then 90
      when playtime_120? then 120
      when playtime_150? then 150
      when playtime_180? then 180
      when playtime_210? then 210
      when playtime_240? then 240
      when playtime_300? then 300
      when playtime_360? then 360
      else 0
      end
  end

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

  private

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
