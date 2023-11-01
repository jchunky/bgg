ATTRS = {
  key: "",
  name: "",
  href: "",
  rating: 0.0,
  year: 0,
  play_count: 0,
  rating_count: 0,
  rank: 0,

  couples_rank: 0,
  solo_rank: 0,

  bgg_rank: 0,
  vote_rank: 0,
  play_rank: 0,
  votes_per_year_rank: 0,

  **Categories::RANK_FIELDS.to_h { |name| ["#{name}_rank".to_sym, 0] },
}

class Game < Struct.new(*ATTRS.keys, keyword_init: true)
  include Categories

  def initialize(args)
    super(ATTRS.to_h { |attr, default| [attr, args.fetch(attr, default)] })
  end

  def merge(other)
    Game.new(members.to_h { |attr| [attr, merge_attr(attr, other)] })
  end

  def votes_per_year
    return 0 if year.zero?
    years = (Date.today.year + 1) - year
    years = 1 if years < 1

    rating_count / years
  end

  def weight
    WEIGHT_FIELDS.each do |field, i|
      return i if send("#{field}_rank") > 0
    end
    nil
  end

  def player_count
    return unless player_count_min && player_count_max
    return player_count_min if player_count_min == player_count_max

    [player_count_min, player_count_max].join("-")
  end

  def player_count_min
    PLAYER_COUNT_FIELDS.each do |field, i|
      return i if send("#{field}_rank") > 0
    end
    nil
  end

  def player_count_max
    PLAYER_COUNT_FIELDS.reverse_each do |field, i|
      return i if send("#{field}_rank") > 0
    end
    nil
  end

  def mechanics
    MECHANICS.keys.select { |m| send("#{m}_rank") > 0 }
  end

  def subdomain
    SUBDOMAINS.keys.select { |s| send("#{s}_rank") > 0 }
  end

  def solo?
    player_count_min.to_i == 1
  end

  Categories::CATEGORIES.each do |category|
    define_method("#{category}?") do
      send("#{category}_rank") > 0
    end
  end

  private

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
