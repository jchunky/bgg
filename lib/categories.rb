module Categories
  MECHANICS = {
    coop: 2023,
    campaign: 2822,
    card_driven: 2018,
    dice: 2072,
    flicking: 2860,
    legacy: 2824,
    narrative_choice: 2851,
    realtime: 2831,
    stacking: 2988,
    storytelling: 2027,
  }

  SUBDOMAINS = {
    thematic: 5496,
    abstract: 4666,
    child: 4665,
    customizable: 4667,
    family: 5499,
    party: 5498,
    strategy: 5497,
    war: 4664,
  }

  PLAYER_COUNT_FIELDS = 1.upto(10).to_h { |i| ["player_count_#{i}", i] }
  WEIGHT_FIELDS = (1..4.5).step(0.5).to_h { |i| ["weight_#{i.to_s.split('.').join('_')}", i] }

  CATEGORIES = MECHANICS.keys + SUBDOMAINS.keys
  RANK_FIELDS = CATEGORIES + PLAYER_COUNT_FIELDS.keys + WEIGHT_FIELDS.keys
end
