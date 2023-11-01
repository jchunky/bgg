CATEGORIES = MECHANICS.keys + SUBDOMAINS.keys

PLAYER_COUNT_RANKS = (1..10).step(0.5).to_h { |i| ["player_count_#{i}_rank".to_sym, 0] }
WEIGHT_RANKS = (1..4.5).step(0.5).to_h { |i| ["weight_#{i.to_s.split('.').join('_')}_rank".to_sym, 0] }

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

  **PLAYER_COUNT_RANKS,
  **WEIGHT_RANKS,

  **MECHANICS.keys.to_h { |m| ["#{m}_rank".to_sym, 0] },
  **SUBDOMAINS.keys.to_h { |s| ["#{s}_rank".to_sym, 0] },
}

Game = Struct.new(*ATTRS.keys, keyword_init: true) do
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
    (1..4.5).step(0.5) do |i|
      return i if send("weight_#{i.to_s.split('.').join('_')}_rank") > 0
    end
    nil
  end

  def player_count
    return unless player_count_min && player_count_max
    return player_count_min if player_count_min == player_count_max

    [player_count_min, player_count_max].join("-")
  end

  def player_count_min
    1.upto(10) do |i|
      return i if send("player_count_#{i}_rank") > 0
    end
    nil
  end

  def player_count_max
    10.downto(1) do |i|
      return i if send("player_count_#{i}_rank") > 0
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

  CATEGORIES.each do |category|
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
