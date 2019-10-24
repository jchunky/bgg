class SnakeName
  NAMES = {
    "Agricola (2015)" => "Agricola",
    "Alien Frontiers 5th Edition" => "Alien Frontiers",
    "Arkham Horror - 3rd Edition" => "Arkham Horror (Third Edition)",
    "Avalon" => "The Resistance: Avalon",
    "Betrayal at the House on the Hill" => "Betrayal at House on the Hill",
    "Blokus Refresh" => "Blokus",
    "Cash'N Guns" => "Ca$h 'n Guns (Second Edition)",
    "Catan (5th Edition)" => "Catan",
    "Citadels (Classic)" => "Citadels",
    "Clank!" => "Clank!: A Deck-Building Adventure",
    "Deception: Murder in HK" => "Deception: Murder in Hong Kong",
    "Eclipse: New Dawn" => "Eclipse",
    "Game of Thrones 2nd Edition" => "A Game of Thrones: The Board Game (Second Edition)",
    "Ganz Schon Clever (That's Pretty Clever!)" => "That's Pretty Clever",
    "Lanterns" => "Lanterns: The Harvest Festival",
    "Legendary: Marvel Deck-Building Game" => "Legendary: A Marvel Deck Building Game",
    "Love Letter Premium Edition" => "Love Letter Premium",
    "Love Letter: Clamshell Edition" => "Love Letter",
    "Netrunner (Revised Core)" => "Android: Netrunner",
    "NMBR9" => "NMBR 9",
    "Once Upon a Time" => "Once Upon a Time: The Storytelling Card Game",
    "Perudo" => "Liar's Dice",
    "Resistance - 3rd Edition" => "The Resistance",
    "Sentinels of the Multiverse: Enhanced Edition" => "Sentinels of the Multiverse",
    "Star Realms Deck-Building Game" => "Star Realms",
    "Survive: 30th Anniversary Edition" => "Survive: Escape from Atlantis!",
    "The Game: On Fire" => "The Game",
    "Vegas (formerly Las Vegas)" => "Las Vegas",
    "Welcome to... Your Perfect Home" => "Welcome to...",
  }

  def self.normalize(name)
    name = name.strip
    NAMES[name] || name
  end
end
