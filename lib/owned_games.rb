class OwnedGames
  OWNED_GAMES = [
    "After the Virus",
    "Age of War",
    "Alien Frontiers",
    "ALIEN: Fate of the Nostromo",
    "Azul",
    "Battle Line",
    "Bohnanza",
    "Bullet♥︎",
    "Calico",
    "Can't Stop",
    "Captain Carcass",
    "Carcassonne",
    "Cascadia",
    "Castle Panic",
    "CATAN",
    "Citadels",
    "Codenames",
    "Coloretto",
    "Dixit",
    "Dorfromantik: The Board Game",
    "Draftosaurus",
    "Fabled Fruit",
    "For Sale",
    "Furnace",
    "Gloomhaven",
    "Gloomhaven: Jaws of the Lion",
    "Harry Potter: Hogwarts Battle",
    "Herbaceous",
    "Hero Realms",
    "It's a Wonderful World",
    "Jaipur",
    "Just One",
    "Kanagawa",
    "King of Tokyo",
    "Kingdom Builder",
    "Kingdomino",
    "Kingsburg",
    "Las Vegas",
    "Lords of Waterdeep",
    "Love Letter",
    "Marvel Champions: The Card Game",
    "Marvel United",
    "Meadow",
    "MicroMacro: Crime City",
    "Mists over Carcassonne",
    "No Thanks!",
    "Oltréé",
    "Paleo",
    "Patchwork",
    "Point Salad",
    "Potion Explosion",
    "Qwirkle",
    "Qwixx",
    "Race for the Galaxy",
    "Race to the Raft",
    "Sagrada",
    "San Juan",
    "SCOUT",
    "Sequence",
    "Skull",
    "Sky Team",
    "Splendor",
    "Star Realms",
    "Take 5",
    "Tales from the Red Dragon Inn",
    "Terraforming Mars: Ares Expedition",
    "The Crew: The Quest for Planet Nine",
    "The Initiative",
    "The Isle of Cats",
    "The LOOP",
    "The Lord of the Rings: The Card Game",
    "The Mind",
    "Ticket to Ride",
    "Timeline",
    "Tiny Towns",
    "Turing Machine",
    "Wingspan",
    "Wits & Wagers",
    "World of Warcraft: Wrath of the Lich King",
    "Zombicide: 2nd Edition",
    "Zombie Dice",
  ]

  def self.include?(game)
    OWNED_GAMES.include?(game.name)
  end
end
