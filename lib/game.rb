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
      ("abstract" if abstract?),
      ("ccg" if ccg?),
      ("child" if child?),
      ("family" if family?),
      ("party" if party?),
      ("strategy" if strategy?),
      ("thematic" if thematic?),
      ("war" if war?),
    ].compact.join(", ")
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

  def player_1?
    player_1_rank > 0
  end

  def player_2?
    player_2_rank > 0
  end

  def player_3?
    player_3_rank > 0
  end

  def player_4?
    player_4_rank > 0
  end

  def player_5?
    player_5_rank > 0
  end

  def player_6?
    player_6_rank > 0
  end

  def player_7?
    player_7_rank > 0
  end

  def player_8?
    player_8_rank > 0
  end

  def player_9?
    player_9_rank > 0
  end

  def player_10?
    player_10_rank > 0
  end

  def player_11?
    player_11_rank > 0
  end

  def player_12?
    player_12_rank > 0
  end

  def abstract?
    abstract_rank > 0
  end

  def family?
    family_rank > 0
  end

  def thematic?
    thematic_rank > 0
  end

  def party?
    party_rank > 0
  end

  def war?
    war_rank > 0
  end

  def strategy?
    strategy_rank > 0
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
