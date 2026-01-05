class Game
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
        result << :snakes if snakes?
        result << :bgb if bgb?
        result << :preorder if preorder?
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
    def b2go? = b2go == true
    def bgb? = (bgb == true && !preorder?)
    def crowdfunded? = kickstarter? || gamefound? || backerkit?
    def play_rank? = (play_rank > 0)
    def played? = (played == true)
    def preorder? = (preorder == true)
    def snakes? = snakes == true
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

    def highlight?
      [
        "7 Wonders",
        "7 Wonders: Architects",
        "Agent Avenue ",
        "Agricola",
        "Ark Nova",
        "Azul",
        "Carcassonne",
        "Cartographers",
        "Cascadia",
        "CATAN",
        "Clever Cubed ",
        "Cloudspire ",
        "Codenames: Duet",
        "Cribbage ",
        "Dominion",
        "Draftosaurus",
        "Faraway",
        "For Sale",
        "Forest Shuffle",
        "Gizmos ",
        "Gloomhaven: Jaws of the Lion",
        "Hanabi",
        "Harmonies",
        "Hero Realms",
        "HeroQuest",
        "Innovation Ultimate",
        "It's a Wonderful World",
        "King of Tokyo",
        "Kingdom Builder",
        "Kingdomino",
        "Lost Ruins of Arnak",
        "MANTIS ",
        "Marvel United",
        "MicroMacro: Crime City",
        "My City",
        "No Thanks!",
        "Nova Luna",
        "Pandemic",
        "Point Salad",
        "Port Royal",
        "Race for the Galaxy",
        "Railroad Ink: Deep Blue Edition",
        "Res Arcana ",
        "Roll for the Galaxy",
        "Rummikub",
        "Sagrada",
        "Santorini",
        "SCOUT",
        "Sea Salt & Paper",
        "Sequence",
        "Silver & Gold",
        "Skull King",
        "Slay the Spire: The Board Game ",
        "Space Base",
        "Spirit Island",
        "Splendor",
        "Star Wars: Imperial Assault",
        "Stone Age",
        "Tainted Grail: The Fall of Avalon",
        "Terraforming Mars",
        "That's Pretty Clever!",
        "The Crew: Mission Deep Sea",
        "The Crew: The Quest for Planet Nine",
        "The Game",
        "Through the Ages: A New Story of Civilization",
        "Ticket to Ride",
        "Too Many Bones ",
        "Twice as Clever! ",
        "War Chest",
        "Welcome To...",
      ].include?(name)
    end

    def banned?
      %i[
        ccg
        child
        party
        war

        two_player

        dexterity
        digital_hybrid
        realtime
        traitor
        werewolf
      ].any? { send("#{it}?") }
    end
  end

  def key
    @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
  end
end
