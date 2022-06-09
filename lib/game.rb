ATTRS = {
  key: "",
  name: "",
  href: "",
  rating: 0.0,
  year: 0,
  voter_count: 0,
  play_count: 0,

  rank: 0,
  children_rank: 0,
  thematic_rank: 0,
  vote_rank: 0,
  play_rank: 0,

}

Game = Struct.new(*ATTRS.keys, keyword_init: true) do
  def initialize(args)
    super(ATTRS.map { |attr, default| [attr, args.fetch(attr, default)] }.to_h)
  end

  def merge(other)
    Game.new(members.map { |attr| [attr, merge_attr(other, attr)] }.to_h)
  end

  def merge_attr(other, attr)
    value = send(attr)
    other_value = other.send(attr)

    if value.present? && value != 0
      value
    else
      other_value
    end
  end

  def trend
    top_ranked?(play_rank) ? :top_x : :out
  end

  def voter_trend
    top_ranked?(vote_rank) ? :top_x : :out
  end

  private

  def top_ranked?(rank)
    rank && rank.between?(1, Bgg::PLAY_RANK_THRESHOLD)
  end
end
