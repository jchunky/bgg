ATTRS = {
  key: "",
  name: "",
  href: "",
  rating: 0.0,
  year: 0,
  rating_count: 0,
  rank: 0,

  bgg_rank: 0,
  vote_rank: 0,
  votes_per_year_rank: 0,

  weight_1_0_rank: 0,
  weight_1_5_rank: 0,
  weight_2_0_rank: 0,
  weight_2_5_rank: 0,
  weight_3_0_rank: 0,
  weight_3_5_rank: 0,
  weight_4_0_rank: 0,
  weight_4_5_rank: 0,

  player_count_1_rank: 0,
  player_count_2_rank: 0,
  player_count_3_rank: 0,
  player_count_4_rank: 0,
  player_count_5_rank: 0,
  player_count_6_rank: 0,
  player_count_7_rank: 0,
  player_count_8_rank: 0,

  coop_rank: 0,
  campaign_rank: 0,
  card_driven_rank: 0,
  dice_rank: 0,
  legacy_rank: 0,
  storytelling_rank: 0,

  thematic_rank: 0,
  abstract_rank: 0,
  child_rank: 0,
  customizable_rank: 0,
  family_rank: 0,
  party_rank: 0,
  strategy_rank: 0,
  war_rank: 0,
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
    if weight_1_0_rank > 0 then 1.0
    elsif weight_1_5_rank > 0 then 1.5
    elsif weight_2_0_rank > 0 then 2.0
    elsif weight_2_5_rank > 0 then 2.5
    elsif weight_3_0_rank > 0 then 3.0
    elsif weight_3_5_rank > 0 then 3.5
    elsif weight_4_0_rank > 0 then 4.0
    elsif weight_4_5_rank > 0 then 4.5
    end
  end

  def player_count
    return unless player_count_min && player_count_max

    [player_count_min, player_count_max].join("-")
  end

  def player_count_min
    if player_count_1_rank > 0 then 1
    elsif player_count_2_rank > 0 then 2
    elsif player_count_3_rank > 0 then 3
    elsif player_count_4_rank > 0 then 4
    elsif player_count_5_rank > 0 then 5
    elsif player_count_6_rank > 0 then 6
    elsif player_count_7_rank > 0 then 7
    elsif player_count_8_rank > 0 then 8
    end
  end

  def player_count_max
    if player_count_8_rank > 0 then 8
    elsif player_count_7_rank > 0 then 7
    elsif player_count_6_rank > 0 then 6
    elsif player_count_5_rank > 0 then 5
    elsif player_count_4_rank > 0 then 4
    elsif player_count_3_rank > 0 then 3
    elsif player_count_2_rank > 0 then 2
    elsif player_count_1_rank > 0 then 1
    end
  end

  def mechanics
    [
      ("coop" if coop_rank > 0),
      ("campaign" if campaign_rank > 0),
      ("card_driven" if card_driven_rank > 0),
      ("dice" if dice_rank > 0),
      ("legacy" if legacy_rank > 0),
      ("storytelling" if storytelling_rank > 0),
    ].compact
  end

  def subdomain
    [
      ("thematic" if thematic_rank > 0),
      ("abstract" if abstract_rank > 0),
      ("child" if child_rank > 0),
      ("customizable" if customizable_rank > 0),
      ("family" if family_rank > 0),
      ("party" if party_rank > 0),
      ("strategy" if strategy_rank > 0),
      ("war" if war_rank > 0),
    ].compact
  end

  def solo?
    player_count_min.to_i == 1
  end

  def coop?
    coop_rank > 0
  end

  def campaign?
    card_driven_rank > 0 || campaign_rank > 0
  end

  private

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
