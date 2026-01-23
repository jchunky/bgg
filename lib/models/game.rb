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
      return false if whitelisted?
      return true if banned_name?

      [
        :ccg,
        :child,
        :party,
        :war,

        :campaign,
        :ccc,
        :dexterity,
        :digital_hybrid,
        :realtime,
        :skirmish,
        :traitor,
        :werewolf,
      ].any? { send("#{it}?") }
    end

    def whitelisted?
      [
        "D-Day Dice",
        "Detective: A Modern Crime Board Game – Season One",
        "Detective: A Modern Crime Board Game",
      ].include?(name)
    end
  end

  concerning :Customize do
    def banned_name?
      [
        "Bureau of Investigation",
        "Cantaloop",
        "Chronicles of Crime",
        "Deckscape",
        "EXIT: The Game",
        "Rory's Story Cubes",
        "Sherlock Holmes Consulting Detective",
        "Tiny Epic",
        "Unlock!",
      ].any? { name.start_with?(it) }
    end

    def b2go?
      b2go == true || [
        "5-Minute Mystery",
        "Arkham Horror (Third Edition)",
        "Atlantis Rising (Second Edition)",
        "Bardsung",
        "Darkest Dungeon: The Board Game",
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
        "Street Masters: Tide of the Dragon ",
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

    def skirmish?
      [
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
