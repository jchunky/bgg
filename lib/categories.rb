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
    stacking: 2988,
    storytelling: 2027,
  }

  FAMILIES = {
    app: 41489,
    bga: 70360,
    crowdfunding: 8374,
    # crowdfunding: [8374, 16972, 18211, 20530, 22135, 22152, 22706, 23287, 25292, 27053, 28659, 44353, 50203, 50563, 66292, 67121, 68115, 70949, 73331, 75218, 76292, 77267],
  }

  CATEGORIES = MECHANICS.keys + FAMILIES.keys
end
