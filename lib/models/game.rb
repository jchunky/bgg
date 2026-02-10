class Game
  LEARNED = File.read("./data/learned.txt").split("\n").reject(&:blank?)
  REPLAYED = File.read("./data/replayed.txt").split("\n").reject(&:blank?)
  PLAYED = File.read("./data/played_games.txt").split("\n").reject(&:blank?)

  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new(0).merge(args)
  end

  concerning :Categories do
    def category_label
      @category_label ||= begin
        result = categories
        result << :b2go if b2go?
        result << :bgb if bgb?
        result << :ccc if ccc?
        result << :preorder if preorder?
        result << :snakes if snakes?
        result.sort.join(", ")
      end
    end

    def categories
      @categories ||= Downloaders::CATEGORIES.map(&:prefix).select { send(:"#{_1}?") }
    end

    def subdomains
      @subdomains ||= Downloaders::SUBDOMAINS.map(&:prefix).select { send(:"#{_1}?") }.join(", ")
    end
  end

  concerning :Attributes do
    def method_missing(method_name, *args)
      attribute_name = method_name.to_s.chomp("=").chomp("?").to_sym
      if method_name.to_s.end_with?("=")
        attributes[attribute_name] = args.first
      elsif method_name.to_s.end_with?("?")
        !null?(send(:"#{attribute_name}_rank"))
      else
        attributes[attribute_name]
      end
    end

    def merge(other)
      Game.new(attributes.merge(other.attributes)) { |_, a, b| null?(a) ? b : a }
    end

    private

    def null?(value)
      !value || (value.respond_to?(:zero?) && value.zero?)
    end
  end

  concerning :GameData do
    def bgb? = (bgb == true && !preorder?)
    def crowdfunded? = kickstarter? || gamefound? || backerkit?
    def play_rank? = (play_rank > 0)
    def played? = (played == true)
    def preorder? = (preorder == true)
    def snakes? = snakes == true
    def learned? = LEARNED.include?(name)
    def replayed? = REPLAYED.include?(name)
    def played? = PLAYED.include?(name)
    def soloable? = max_player_count == 1 || (coop? && min_player_count == 1)
    def normalized_price = (bgb_price > 0 ? bgb_price : price).to_f.round
    def player_count = ([min_player_count, max_player_count].compact.uniq.join("-"))
    def player_count_range = (min_player_count..max_player_count)
    def snakes_category = snakes_location.to_i
    def snakes_location_label = null?(snakes_location) ? nil : snakes_location
    def one_player? = max_player_count == 1
    def two_player? = max_player_count == 2
    def competitive? = group == "competitive"

    def votes_per_year
      days_published = ((Time.now.year - year.to_i) * 365) + Time.now.yday
      years_published = days_published.to_f / 365

      (rating_count / years_published).round
    end

    def group
      case
      when party? then "party"
      when coop? then "coop"
      when one_player? then "1-player"
      when two_player? then "2-player"
      else "competitive"
      end
    end

    def banned?
      return true if banned_game?
      return true if banned_series?

      [
        # :ccg,
        :child,
        :party,
        # :war,

        # :campaign,
        :ccc,
        :dexterity,
        :digital_hybrid,
        :realtime,
        :skirmish,
        :traitor,
        :werewolf,
      ].any? { send("#{_1}?") }
    end

    def min_player_count
      return 1 if one_player_game_1?
      return 1 if one_player_game_2?

      super
    end
  end

  concerning :Customize do
    def keep?
      [
        "1941: Race to Moscow",
        "Bastion",
        "Boblin's Rebellion",
        "Bremerhaven",
        "Castles by the Sea",
        "Catacombs Cubes",
        "Come Sail Away!",
        "Detective: A Modern Crime Board Game",
        "Dungeon Exit",
        "Expeditions",
        "Explorers of the North Sea",
        "Fallout",
        "Fuji Koro",
        "Imperium: Classics",
        "Kingswood",
        "Masters of the Night",
        "Medici: The Dice Game",
        "Pandoria Merchants",
        "Relics of Rajavihara R",
        "Rossio",
        "Ruins of Mars",
        "Secrets of the Lost Station",
        "Small Islands",
        "Sparks",
        "Super-Skill Pinball: 4-Cade",
        "Terraforming Mars",
        "The Abandons",
        "The Everrain",
        "The Refuge: Terror from the Deep",
        "Tumble Town",
        "X-Men: Mutant Insurrection",
      ].include?(name)
    end

    def banned_game?
      [
        "Annapurna",
        "Aquatica",
        "Atlantis Exodus",
        "Barrage",
        "BattleCON: Devastation of Indines",
        "Between Two Cities Essential Edition",
        "Between Two Cities",
        "Big Easy Busking",
        "Chai",
        "Chakra",
        "Crusader Kings",
        "Dexikon",
        "Dragon Ball Z: Perfect Cell",
        "Dragon Castle",
        "Drinkopoly",
        "Dune: War for Arrakis",
        "Dungeon Run",
        "Embarcadero",
        "Figment",
        "Free Ride USA",
        "Gentes",
        "Gnomopolis",
        "Golden Cup",
        "Kiwi Chow Down",
        "Living Forest",
        "Living Planet",
        "Lords of Ragnarok",
        "Mercado de Lisboa",
        "Merv: The Heart of the Silk Road",
        "Monster Soup",
        "My First Bananagrams",
        "Neta-Tanka",
        "Nutty Squirrels of the Oakwood Forest",
        "Oros",
        "Otys",
        "Pax Viking",
        "Quiddler",
        "QuizWiz",
        "Roll In One",
        "Scuttle!",
        "Smartphone Inc.",
        "Snappy Dressers",
        "Starfall",
        "Super Boss Monster",
        "Tales of the Arabian Nights",
        "The Princes of Florence",
        "Tokaido",
        "Vast: The Crystal Caverns",
        "Vast: The Mysterious Manor",
        "War For Chicken Island",
        "Wordsmith",
      ].any? { name == _1 }
    end

    def banned_series?
      [
        "Bureau of Investigation",
        "Cantaloop",
        "Chronicles of Crime",
        "Clue Escape",
        "Deckscape",
        "EXIT: The Game",
        "Rory's Story Cubes",
        "Sherlock Holmes Consulting Detective",
        "Tiny Epic",
        "Unlock!",
      ].any? { name.start_with?(_1) }
    end

    def b2go?
      b2go == true || [
        "5-Minute Mystery",
        "Arkham Horror (Third Edition)",
        "Atlantis Rising (Second Edition)",
        "Bardsung",
        "Darkest Dungeon: The Board Game",
        "Expeditions",
        "Final Girl",
        "First Orchard",
        "Flatline",
        "Frostpunk: The Board Game",
        "Horrified: American Monsters",
        "Kick-Ass: The Board Game",
        "Mansions of Madness: Second Edition",
        "Night of the Living Dead: A Zombicide Game",
        "Sherlock Holmes Consulting Detective: Carlton House & Queen's Park",
        "Sherlock Holmes Consulting Detective: Jack the Ripper & West End Adventures",
        "Sherlock Holmes Consulting Detective: The Baker Street Irregulars",
        "Sherlock Holmes Consulting Detective: The Thames Murders & Other Cases",
        "Street Masters: Tide of the Dragon",
        "The Dresden Files Cooperative Card Game",
        "The Elder Scrolls: Betrayal of the Second Era",
        "The Lord of the Rings: Journeys in Middle-Earth",
        "Vienna Connection",
        "Waste Knights: Second Edition",
      ].include?(name)
    end

    def ccc?
      super || [
        "Night of the Living Dead: A Zombicide Game",
        "Resident Evil 3: The Board Game",
        "Shadows of Brimstone: Swamps of Death",
        "Sword & Sorcery: Ancient Chronicles",
      ].include?(name)
    end

    def weight
      {
        "Annapurna" => 1.60,
        "Boblin's Rebellion" => 2.50,
        "Bone Wars" => 3.88,
        "Drinkopoly" => 1.00,
        "Everdell Farshore" => 2.21,
        "Free Ride USA" => 2.40,
        "Globetrotting" => 1.73,
        "Golden Cup" => 1.83,
        "Golfie" => 1.07,
        "Nutty Squirrels of the Oakwood Forest" => 1.75,
        "Silicon Valley" => 2.50,
        "Square One" => 1.90,
        "Stamp Swap" => 2.85,
      }.fetch(name, super)
    end

    def child?
      super || [
        "Flower Fairy",
      ].include?(name)
    end

    def skirmish?
      [
        "Hoplomachus: Remastered",
        "Masters of the Universe: The Board Game – Clash for Eternia",
        "Super Punch Fighter",
        "Tiny Epic Tactics",
        "Unmatched Adventures: Tales to Amaze",
        "Wroth",
      ].include?(name)
    end
  end

  def key
    @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
  end
end
