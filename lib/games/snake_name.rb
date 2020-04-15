class SnakeName
  NAMES = {
    'Agricola (2015)' => 'Agricola',
    'Agricola (2016)' => 'Agricola (Revised Edition)',
    'Alien Frontiers 5th Edition' => 'Alien Frontiers',
    'Arkham Horror - 3rd Edition' => 'Arkham Horror (Third Edition)',
    'Avalon' => 'The Resistance: Avalon',
    'Battlestar Galactica' => 'Battlestar Galactica: The Board Game',
    'Betrayal at the House on the Hill' => 'Betrayal at House on the Hill',
    'Blokus Refresh' => 'Blokus',
    'Brass: Birmingham - Deluxe Edition' => 'Brass: Birmingham',
    'Camel Up - Second Edition' => 'Camel Up (Second Edition)',
    "Cash'N Guns" => "Ca$h 'n Guns (Second Edition)",
    'Catan (4th Edition)' => 'Catan',
    'Catan (5th Edition)' => 'Catan',
    'Citadels (Classic)' => 'Citadels',
    'Clank!' => 'Clank!: A Deck-Building Adventure',
    'Deception: Murder in HK' => 'Deception: Murder in Hong Kong',
    'Eclipse' => 'Eclipse Abstract',
    'Eclipse: New Dawn' => 'Eclipse',
    'Fake Artist Goes to New York' => 'A Fake Artist Goes to New York',
    'Game of Thrones 2nd Edition' => 'A Game of Thrones: The Board Game (Second Edition)',
    "Ganz Schon Clever (That's Pretty Clever!)" => "That's Pretty Clever",
    'Go - 12' => 'Go',
    'King of Tokyo (2016 edition)' => 'King of Tokyo',
    'Lanterns' => 'Lanterns: The Harvest Festival',
    'Legendary: Marvel Deck-Building Game' => 'Legendary: A Marvel Deck Building Game',
    'Love Letter Premium Edition' => 'Love Letter Premium',
    'Love Letter: Clamshell Edition' => 'Love Letter',
    'Love Letter: Kanai Factory Limited Edition' => 'Love Letter',
    'Mr. Jack London' => 'Mr. Jack',
    'Netrunner (Revised Core)' => 'Android: Netrunner',
    'NMBR9' => 'NMBR 9',
    'Plague Inc.' => 'Plague Inc.: The Board Game',
    'Resistance - 3rd Edition' => 'The Resistance',
    'Sentinels of the Multiverse: Enhanced Edition' => 'Sentinels of the Multiverse',
    'Skull & Roses' => 'Skull',
    'Star Realms Deck-Building Game' => 'Star Realms',
    'Survive: 30th Anniversary Edition' => 'Survive: Escape from Atlantis!',
    'The Game: On Fire' => 'The Game',
    'Vegas (formerly Las Vegas)' => 'Las Vegas',
    'Villainous' => 'Disney Villainous',
    'Welcome to... Your Perfect Home' => 'Welcome to...'
  }

  def self.normalize(name)
    name = name.strip
    NAMES[name] || name
  end
end
