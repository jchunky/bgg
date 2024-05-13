module Categories
  MECHANICS = {
    action_points: 2001,
    campaign: 2822,
    card_driven: 2018,
    coop: 2023,
    deck_building: 2664,
    dice: 2072,
    flicking: 2860,
    legacy: 2824,
    narrative_choice: 2851,
    realtime: 2831,
    solitaire: 2819,
    stacking: 2988,
    storytelling: 2027,
    variable_player_powers: 2015,
    variable_setup: 2897,
    worker_placement: 2082,
  }

  FAMILIES = {
    app: 41489,
    bga: 70360,
    crowdfunding: [8374, 66292],
    dungeon_crawl: 59218,
    flip_and_write: 66143,
    tableau_building: 27646,
  }

  CATEGORIES = MECHANICS.keys + FAMILIES.keys
end
