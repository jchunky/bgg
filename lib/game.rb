ATTRS = {
  key: "",
  name: "",
  href: "",
  rating: 0.0,
  year: 0,
  play_count: 0,

  rank: 0,
  children_rank: 0,
  family_rank: 0,
  party_rank: 0,
  play_rank: 0,
  strategy_rank: 0,
  thematic_rank: 0,
  vote_rank: 0,
  solo_rank: 0,
  couples_rank: 0,
  rating_count: 0,
}

Game = Struct.new(*ATTRS.keys, keyword_init: true) do
  def initialize(args)
    super(ATTRS.to_h { |attr, default| [attr, args.fetch(attr, default)] })
  end

  def merge(other)
    Game.new(members.to_h { |attr| [attr, merge_attr(attr, other)] })
  end

  private

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
