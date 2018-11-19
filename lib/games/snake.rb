require 'json'

class Snake
  NAMES = {
    "(BlackBox) - Exploding Kittens - 1st edition" => "Exploding Kittens",
    "(BlackBox) Exploding Kittens NSFW Deck" => "Exploding Kittens: NSFW Deck",
    "Abraca What?" => "Abracada...What?",
    "Agricola (2015)" => "Agricola (Revised Edition)",
    "Alien Frontiers 5th Edition" => "Alien Frontiers",
    "Alles Trolli" => "Alles Tomate!",
    "Apples to Apples: Party Box Refresh" => "Apples to Apples",
    "Arkham Horror - 3rd Edition" => "Arkham Horror",
    "Atari Missile Command" => "Atari's Missile Command",
    "Avalon" => "The Resistance: Avalon",
    "Bang! 4th Edition" => "BANG!",
    "Betrayal at the House on the Hill" => "Betrayal at House on the Hill",
    "Blackbox - Joking Hazard (White Box Edition)" => "Joking Hazard",
    "Blokus Refresh" => "Blokus",
    "Blood Bowl Team Manager" => "Blood Bowl: Team Manager ? The Card Game",
    "Bob Ross: the Art of Chill" => "Bob Ross: Art of Chill Game",
    "Bonkers, the Game of" => "This Game is Bonkers!",
    "Boss Monster: Master of the Dungeon" => "Boss Monster: The Dungeon Building Card Game",
    "Brave Rats" => "BraveRats",
    "Britannia the game of the Birth of Britain" => "Britannia",
    "Buy Word" => "BuyWord",
    "Camel Up - Second Edition" => "Camel Up",
    "Candyland" => "Candy Land",
    "Carcassonne: My First Carcassonne" => "My First Carcassonne",
    "Cards Against Humanity (Canadian version)" => "Cards Against Humanity",
    "Cash'N Guns" => "Ca$h 'n Guns (Second Edition)",
    "Catan (5th Edition)" => "Catan",
    "Catan, 5-6 Extension (4th Edition)" => "Catan: 5-6 Player Extension",
    "Checkers - 11.5" => "Checkers",
    "Chess - Folding Board - SET OAK BOOK STYLE 11\" (W/ HANDLE)" => "Chess",
    "Citadels (Classic)" => "Citadels",
    "Connect 4" => "Connect Four",
    "Cranium Party" => "Cranium",
    "Cribbage Board - Board Large 29 3 Track" => "Cribbage",
    "D&D: Castle Ravenloft" => "Dungeons & Dragons: Castle Ravenloft Board Game",
    "D&D: Dungeon!" => "Dungeon!",
    "Deception: Murder in HK" => "Deception: Murder in Hong Kong",
    "Dirty Minds Card Game" => "Dirty Minds: The Game of Naughty Clues",
    "Dominoes: Double 6" => "Dominoes",
    "Eclipse: New Dawn" => "Eclipse",
    "Fake Artist Goes to New York" => "A Fake Artist Goes to New York",
    "Fantome de l'Opera" => "Le Fantome de l'Opera",
    "Fluxx: Adventure Time Fluxx" => "Adventure Time Fluxx",
    "Friends Ultimate Trivia" => "Friends Trivia Game",
    "Game of Life Monsters Inc" => "The Game of Life in Monstropolis",
    "Game of Things" => "Things...",
    "Game of Thrones 2nd Edition" => "A Game of Thrones: The Board Game (Second Edition)",
    "Gloom (2nd Edition)" => "Gloom",
    "Gloom Cthulhu" => "Cthulhu Gloom",
    "Go - 12" => "Go",
    "Grey's Anatomy" => "Grey's Anatomy Trivia Board Game",
    "Grid Stones: Night Sky" => "Gridstones",
    "Hedbanz Adult" => "Hedbanz for Adults!",
    "Hedbanz No Limits" => "Hedbanz for Adults!",
    "Hotels" => "Hotel Tycoon",
    "Jenga Refresh" => "Jenga",
    "Joking Hazard (White Box Edition)" => "Joking Hazard",
    "Jungle Speed (Plastic)" => "Jungle Speed",
    "Kwizniac 2" => "Kwizniac",
    "Lanterns" => "Lanterns: The Harvest Festival",
    "Last Night on Earth" => "Last Night on Earth: The Zombie Game",
    "Legendary: Marvel Deck-Building Game" => "Legendary: A Marvel Deck Building Game",
    "Lift It! Deluxe" => "Lift It!",
    "Loaded Questions The Game" => "Loaded Questions",
    "Lord of the Rings Co-op" => "Lord of the Rings",
    "Lord of the Rings: Fellowship of the Ring DBG" => "The Lord of the Rings: The Fellowship of the Ring Deck-Building Game",
    "Love Letter Premium Edition" => "Love Letter Premium",
    "Love Letter: Clamshell Edition" => "Love Letter",
    "Love Letter: Kanai Factory Limited Edition" => "Love Letter",
    "Mind Trap" => "MindTrap",
    "Monopoly Jr." => "Monopoly Junior",
    "Mr. Jack London" => "Mr. Jack",
    "Netrunner (Revised Core)" => "Android: Netrunner",
    "Never Have I Ever" => "Never Have I Ever: The Card Game of Poor Life Decisions",
    "NMBR9" => "NMBR 9",
    "Once Upon a Time" => "Once Upon a Time: The Storytelling Card Game",
    "Orinoco Gold" => "Gold am Orinoko",
    "Parcheesi" => "Pachisi",
    "Penguin Pile Up" => "Iceberg Seals",
    "Pentago Multiplayer" => "Multiplayer Pentago",
    "Perudo" => "Liar's Dice",
    "Pick Your Poison - NSFW Edition" => "Pick Your Poison: NSFW Edition",
    "Plague Inc." => "Plague Inc.: The Board Game",
    "Playing Cards" => "Traditional Card Games",
    "Poison" => "Friday the 13th",
    "Portrayal" => "Duplik",
    "Quartex EN/FR" => "Quartex",
    "Resistance - 3rd Edition" => "The Resistance",
    "Rick and Morty: Total Rickall" => "Rick and Morty: Total Rickall Card Game",
    "Rock Paper Wizard" => "Dungeons & Dragons: Rock Paper Wizard",
    "Sentinels of the Multiverse: Enhanced Edition" => "Sentinels of the Multiverse",
    "Shrimp Cocktail" => "Shrimp",
    "Simpsons Trivia" => "The Simpsons Trivia Game",
    "Snakes and Ladders" => "Chutes and Ladders",
    "Spank the Yeti" => "Spank the Yeti: The Adult Party Game of Questionable Decisions",
    "Spartacus: Blood and Treachery" => "Spartacus: A Game of Blood & Treachery",
    "Star Realms Deck-Building Game" => "Star Realms",
    "Star Wars Loopin Chewie" => "Loopin' Chewie",
    "Star Wars Trivial Pursuit" => "Trivial Pursuit: Star Wars – The Black Series Edition",
    "Survive: 30th Anniversary Edition" => "Survive: Escape from Atlantis!",
    "Taboo Refresh" => "Taboo",
    "Telestrations Party Pack " => "Telestrations: 12 Player Party Pack ",
    "Telestrations Party Pack" => "Telestrations: 12 Player Party Pack",
    "The Game: On Fire" => "The Game",
    "The Hare & The Tortoise" => "Tales & Games: The Hare & the Tortoise",
    "The Office" => "The Office Trivia Game",
    "Three Little Pigs" => "Tales & Games: The Three Little Pigs",
    "Timeline Science & Discoveries (formerly Timeline Discoveries)" => "Timeline: Discoveries",
    "Trivial Pursuit 2000s" => "Trivial Pursuit: 2000s Edition",
    "Trivial Pursuit Classic" => "Trivial Pursuit",
    "Trivial Pursuit Disney" => "Trivial Pursuit: Disney Edition",
    "Trivial Pursuit Harry Potter" => "Trivial Pursuit: World of Harry Potter",
    "Trivial Pursuit Warner Bros" => "Trivial Pursuit: Warner Bros. All Family Edition",
    "Trivial Pursuit: Dr. Who" => "Trivial Pursuit: Doctor Who",
    "Vegas (formerly Las Vegas)" => "Las Vegas",
    "Welcome to... Your Perfect Home" => "Welcome to...",
    "What Do You Meme" => "What do you Meme?: A Millennial Card Game For Millennials And Their Millennial Friends",
    "Wikipedia - The Game" => "Wikipedia: The Game About Everything ",
    "Wildlife Safari (formerly Botswana)" => "Wildlife Safari",
    "Word Around" => "WordARound",
  }

  FILES = [
    'input/abstract.json',
    'input/childrens.json',
    'input/cooperative.json',
    'input/dexterity.json',
    'input/greatest_hits.json',
    'input/light_strategy.json',
    'input/new_arrivals.json',
    'input/nostalgia.json',
    'input/party.json',
    'input/strategy.json',
    'input/trivia.json',
    'input/word.json',
  ]

  def games
    FILES
      .map { |f| File.read(f) }
      .map { |f| JSON.parse(f) }
      .flat_map do |rows|
        rows.map { |row| build_game(row) }
      end
  end

  def build_game(data)
    name = normalize_name(data['title'])
    all_categoires = ["Children's", "Cooperative", "Party", "Light Strategy", "Strategy", "Word", "Abstract", "Trivia", "Greatest Hits"]
    game_catagories = data['categories'].map { |c| c['name'] }
    category = all_categoires.find { |c| game_catagories.include?(c) }

    OpenStruct.new(
      name: name,
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      location: data['shelf_location'],
      categories: category,
      key: Utils.generate_key(name),

      ts_added: data['ts_added'],
      ts_updated: data['ts_updated'],
      ts_maintenance: data['ts_maintenance'],
      thumb_src: data['thumb_src'],
      image_src: data['image_src'],
      has_guide: data['has_guide'],
      archived: data['archived'],
      parts_copy: data['parts_copy'],
      damaged: data['damaged'],
      notes: data['notes'],
      maintenance_frequency: data['maintenance_frequency'],
      default_maintenance_frequency: data['default_maintenance_frequency'],
      teach_time: data['teach_time'],
      curation_notes: data['curation_notes'],
      optimal_players: data['optimal_players'],
      two_player_label: data['2player_label'],
      solo_label: data['solo_label'],
      sell_product: data['sell_product'],
      shelf_copies: data['shelf_copies'],
      title_url: data['title_url'],
      employees_played: (data['employees_played'].size rescue 0),
      employees_teachable: (data['employees_teachable'].size rescue 0),
      employee_played: data['employee_played'],
      employee_teachable: data['employee_teachable'],
      ts_maintenance_next: data['ts_maintenance_next']
    )
  end

  def normalize_name(name)
    name = name.strip
    NAMES[name] || name
  end
end
