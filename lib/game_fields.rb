module GameFields
  FIELDS = {
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
end
