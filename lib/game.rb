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

  light_rank: 0,

  solo_rank: 0,
  five_player_rank: 0,

  coop_rank: 0,
  campaign_rank: 0,
  card_driven_rank: 0,
  dice_rank: 0,
  legacy_rank: 0,
  storytelling_rank: 0,

  abstract_rank: 0,
  child_rank: 0,
  customizable_rank: 0,
  family_rank: 0,
  party_rank: 0,
  strategy_rank: 0,
  thematic_rank: 0,
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
    return "light" if light_rank > 0
  end

  def player_count
    [
      ("solo" if solo_rank > 0),
      ("five_player" if five_player_rank > 0)
    ].compact
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
      ("abstract" if abstract_rank > 0),
      ("child" if child_rank > 0),
      ("customizable" if customizable_rank > 0),
      ("family" if family_rank > 0),
      ("party" if party_rank > 0),
      ("strategy" if strategy_rank > 0),
      ("thematic" if thematic_rank > 0),
      ("war" if war_rank > 0),
    ].compact
  end

  private

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
