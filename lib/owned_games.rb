class OwnedGames
  OWNED_GAMES = [
    "After the Virus",
    "Age of War",
    "Alien Frontiers",
    "ALIEN: Fate of the Nostromo",
    "Azul",
    "Bohnanza",
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
    "Jaipur",
    "Just One",
    "Kanagawa",
    "King of Tokyo",
    "Kingsburg",
    "Las Vegas",
    "Lords of Waterdeep",
    "Love Letter",
    "Marvel Champions: The Card Game",
    "Meadow",
    "MicroMacro: Crime City",
    "No Thanks!",
    "Oltréé",
    "Paleo",
    "Patchwork",
    "Potion Explosion",
    "Qwirkle",
    "Qwixx",
    "Race for the Galaxy",
    "Race to the Raft",
    "San Juan",
    "SCOUT",
    "Sequence",
    "Skull",
    "Sky Team",
    "Splendor",
    "Star Realms",
    "Take 5",
    "Tales from the Red Dragon Inn",
    "The Crew: The Quest for Planet Nine",
    "The Initiative",
    "The LOOP",
    "The Lord of the Rings: The Card Game",
    "The Mind",
    "Ticket to Ride",
    "Timeline",
    "Wingspan",
    "Wits & Wagers",
    "Zombicide: 2nd Edition",
    "Zombie Dice",
  ]

  def self.include?(game)
    OWNED_GAMES.include?(game.name)
  end
end
