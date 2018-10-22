require 'json'

# {
#   "id"=>"1955",
#   "game_id"=>"2",
#   "ts_added"=>"1399929780",
#   "ts_updated"=>"1527180608",
#   "ts_maintenance"=>"1525808106",
#   "title"=>"1812 The Invasion of Canada",
#   "thumb_src"=>"https://upload.snakesandlattes.com/productsimages/2/.thumbs/2-1.jpg",
#   "image_src"=>"https://upload.snakesandlattes.com/productsimages/2/2-1.jpg",
#   "rules_url"=>"http://upload.snakesandlattes.com/rules/1/1812TheInvasionofCanada.pdf",
#   "has_guide"=>"0",
#   "archived"=>"0",
#   "parts_copy"=>"0",
#   "damaged"=>"0",
#   "notes"=>"Rules need to be laminated",
#   "maintenance_frequency"=>"",
#   "default_maintenance_frequency"=>"",
#   "teach_time"=>"0",
#   "curation_notes"=> "STANDARD AMERICAN BOARD GAME (GREEN) SLEEVES\r\n\r\n1 Map\r\n60 Cards\r\n  12 Red British Regulars\r\n  12 Yellow Canadian Militia\r\n  12 Green Native American\r\n  12 Blue American Regulars\r\n  12 White American Militia\r\n160 Units\r\n  25 Red British Regulars\r\n  35 Yellow Canadian Miltia\r\n  25 Green Native Americans\r\n  30 Blue American Regulars\r\n  45 White American Regulars\r\n13 Battle Dice\r\n  2 Red British Regulars\r\n  3 Yellow Canadian Miltia\r\n  3 Green Native American\r\n  2 Blue American Regulars\r\n  3 White American Militia\r\n1 Round Marker Pawn\r\n20 Control Markers (Double Sided)\r\n5 Turn Order Markers (1 of each colour)\r\n",
#   "optimal_players"=>"5",
#   "difficulty_label"=>"3",
#   "2player_label"=>"1",
#   "solo_label"=>"0",
#   "sell_product"=>"1",
#   "shelf_location"=>"34E",
#   "categories"=>[{"id"=>"1", "name"=>"Strategy"}],
#   "title_url"=>"1812-The-Invasion-of-Canada",
#   "employees_played"=>["AaronSlade", "AaronZack", "AnsisKalnins", "MikhailHonoridez"],
#   "employees_teachable"=>["JoanMoriarity", "MikhailHonoridez", "ToddCampbell"],
#   "employee_played"=>0,
#   "employee_teachable"=>0,
#   "ts_maintenance_next"=>1557344106
# }
class Snake
  NAMES = {
    "1812 The Invasion of Canada" => "1812: The Invasion of Canada",
    "Agricola (2015)" => "Agricola (Revised Edition)",
    "Alien Frontiers 5th Edition" => "Alien Frontiers",
    "Arkham Horror - 3rd Edition" => "Arkham Horror",
    "Betrayal at the House on the Hill" => "Betrayal at House on the Hill",
    "Blood Bowl Team Manager" => "Blood Bowl: Team Manager ? The Card Game",
    "Britannia the game of the Birth of Britain" => "Britannia",
    "Catan (5th Edition)" => "Catan",
    "Catan, 5-6 Extension (4th Edition)" => "Catan: 5-6 Player Extension ",
    "Caverna: Cave VS Cave" => "Caverna: Cave vs Cave",
    "D&D: Castle Ravenloft" => "Dungeons & Dragons: Castle Ravenloft Board Game",
    "D&D: Dungeon!" => "Dungeon!",
    "DC Comics Deck Building Game" => "DC Comics Deck-Building Game",
    "Eclipse: New Dawn" => "Eclipse",
    "Game of Thrones 2nd Edition" => "A Game of Thrones: The Board Game (Second Edition)",
    "Last Night on Earth" => "Last Night on Earth: The Zombie Game",
    "Legendary: Marvel Deck-Building Game" => "Legendary: A Marvel Deck Building Game",
    "Lord of the Rings Co-op" => "Lord of the Rings",
    "Lord of the Rings: Fellowship of the Ring DBG" => "The Lord of the Rings: The Fellowship of the Ring Deck-Building Game",
    "Merchants and Marauders" => "Merchants & Marauders",
    "Netrunner (Revised Core)" => "Android: Netrunner",
    "Power Grid: First Sparks" => "Power Grid: The First Sparks",
    "Risk Lord of the Rings" => "Risk: The Lord of the Rings",
    "Sentinels of the Multiverse: Enhanced Edition" => "Sentinels of the Multiverse",
    "Spartacus: Blood and Treachery" => "Spartacus: A Game of Blood & Treachery",
    "Star Trek Expeditions" => "Star Trek: Expeditions",
    "The Godfather: Corleones Empire" => "The Godfather: Corleone's Empire",
  }

  def games
    games = File.read('input/light_strategy.json')
    games = JSON.parse(games)

    games.flat_map { |data| build_game(data) }
  end

  def build_game(data)
    OpenStruct.new(
      name: normalize_name(data['title']),
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      location: data['shelf_location'],
      categories: data['categories'].map { |c| c['name'] }.join(", ")
    )
  end

  def normalize_name(name)
    NAMES[name] || name
  end
end
