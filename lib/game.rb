ATTRS = {
  key: "",
  name: "",
  href: "",
  rating: 0.0,
  year: 0,
  play_count: 0,
  rating_count: 0,
  rank: 0,

  bgg_rank: 0,
  campaign_rank: 0,
  child_rank: 0,
  couples_rank: 0,
  cyoa_rank: 0,
  family_rank: 0,
  five_rank: 0,
  legacy_rank: 0,
  light_rank: 0,
  play_rank: 0,
  solo_rank: 0,
  vote_rank: 0,
  votes_per_year_rank: 0,
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

  private

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
