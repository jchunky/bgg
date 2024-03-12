require_relative "bgg_games"

module Categories
  MECHANICS = {
    action_points: 2001,
    campaign: 2822,
    card_driven: 2018,
    coop: 2023,
    dice: 2072,
    flicking: 2860,
    legacy: 2824,
    narrative_choice: 2851,
    realtime: 2831,
    solo: 2819,
    stacking: 2988,
    storytelling: 2027,
  }

  FAMILIES = {
    app: 41489,
    bga: 70360,
    kickstarter: 8374,
  }

  CATEGORIES = MECHANICS.keys + FAMILIES.keys
end
