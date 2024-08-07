class PlayedGames
  PLAYED_GAMES = [
    "6 nimmt!",
    "7 Wonders",
    "A Fake Artist Goes to New York",
    "A Feast for Odin",
    "Aeon's End",
    "After the Virus",
    "Age of War",
    "Agricola",
    "Alhambra",
    "Alien Frontiers",
    "ALIEN: Fate of the Nostromo",
    "Arboretum",
    "Ark Nova",
    "Arkham Horror: The Card Game",
    "Ascension: Deckbuilding Game",
    "Awkward Guests: The Walton Case",
    "Azul",
    "BANG!",
    "Battle Line",
    "Blokus",
    "Bohnanza",
    "Brass: Birmingham",
    "Brass: Lancashire",
    "Bullet♥︎",
    "Calico",
    "Camel Up",
    "Can't Stop",
    "Captain Carcass",
    "Carcassonne",
    "Cascadia",
    "Castle Panic",
    "Castles of Mad King Ludwig",
    "Cat in the Box: Deluxe Edition",
    "CATAN",
    "Century: Spice Road",
    "Chronicles of Avel",
    "Citadels",
    "Clank!: A Deck-Building Adventure",
    "Coconuts",
    "Codenames",
    "Coloretto",
    "Concordia",
    "DC Deck-Building Game",
    "Decrypto",
    "Deep Sea Adventure",
    "Dixit",
    "Dominion (Second Edition)",
    "Dorfromantik: The Board Game",
    "Draftosaurus",
    "Dragomino",
    "Elder Sign",
    "Ethnos",
    "Fabled Fruit",
    "Five Tribes: The Djinns of Naqala",
    "For Sale",
    "Forbidden Desert",
    "Friday",
    "Furnace",
    "Gloomhaven",
    "Gloomhaven: Jaws of the Lion",
    "Hanamikoji",
    "Harry Potter: Hogwarts Battle",
    "Herbaceous",
    "Hero Realms",
    "High Society",
    "Hive",
    "Incan Gold",
    "It's a Wonderful World",
    "Jaipur",
    "Jamaica",
    "Just One",
    "Kanagawa",
    "Karak",
    "Karuba",
    "King of Tokyo",
    "Kingdom Builder",
    "Kingdomino",
    "Kingsburg",
    "KLASK",
    "Las Vegas",
    "Legendary: A Marvel Deck Building Game",
    "Lords of Waterdeep",
    "Lost Cities",
    "Love Letter",
    "Machi Koro",
    "Marvel Champions: The Card Game",
    "Marvel United",
    "Marvel United: X-Men",
    "Meadow",
    "MicroMacro: Crime City",
    "Mists over Carcassonne",
    "MLEM: Space Agency",
    "Monopoly Deal Card Game",
    "My First Carcassonne",
    "My Lil' Everdell",
    "Mystic Vale",
    "NMBR 9",
    "No Thanks!",
    "Oh My Goods!",
    "Oltree",
    "One Deck Dungeon",
    "Onirim (Second Edition)",
    "Onitama",
    "Orléans",
    "Outfoxed!",
    "Paleo",
    "Pandemic",
    "Patchwork",
    "Point Salad",
    "Port Royal",
    "Potion Explosion",
    "Puerto Rico",
    "Quarto",
    "Quoridor",
    "Qwirkle",
    "Qwixx",
    "Ra",
    "Race for the Galaxy",
    "Race to the Raft",
    "Raiders of the North Sea",
    "Railroad Ink: Deep Blue Edition",
    "Railroad Ink: Blazing Red Edition",
    "Reef",
    "Resist!",
    "Rhino Hero",
    "Roll For It!",
    "Roll for the Galaxy",
    "Roll Player",
    "Saboteur",
    "Sagrada",
    "Sail",
    "Saint Petersburg",
    "San Juan",
    "Santorini",
    "Schotten Totten",
    "SCOUT",
    "Sequence",
    "SET",
    "Sheriff of Nottingham",
    "Skull",
    "Sky Team",
    "Sleeping Gods",
    "Small World",
    "Space Base",
    "Splendor",
    "Spot it!",
    "Star Realms",
    "Stone Age",
    "Sushi Go Party!",
    "Sushi Go!",
    "Take 5",
    "Take",
    "Takenoko",
    "Tales from the Red Dragon Inn",
    "Targi",
    "Terraforming Mars: Ares Expedition",
    "The Adventures of Robin Hood",
    "The Castles of Burgundy",
    "The Crew: Mission Deep Sea",
    "The Crew: The Quest for Planet Nine",
    "The Game",
    "The Grizzled",
    "The Initiative",
    "The Isle of Cats",
    "The LOOP",
    "The Lord of the Rings: The Card Game",
    "The Lost Expedition",
    "The Mind",
    "The Quacks of Quedlinburg",
    "The Voyages of Marco Polo",
    "This War of Mine: The Board Game",
    "Ticket to Ride",
    "Timeline",
    "Tiny Epic Galaxies",
    "Tiny Towns",
    "Tokaido",
    "Tsuro",
    "Turing Machine",
    "Wavelength",
    "Welcome To...",
    "Wingspan",
    "Wits & Wagers",
    "Zombicide: 2nd Edition",
    "Zombie Dice",
    "Zombie Kidz Evolution",
    "Zombie Teenz Evolution",
  ]

  def self.include?(game)
    PLAYED_GAMES.include?(game.name)
  end
end
