class Game
  LEARNED = File.read("./data/learned.txt").split("\n").reject(&:blank?)
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
    def learned? = LEARNED.include?(name)
    def played? = PLAYED.include?(name)
    def soloable? = max_player_count == 1 || (coop? && min_player_count == 1)
    def normalized_price = (bgb_price > 0 ? bgb_price : price).to_f.round
    def player_count = ([min_player_count, max_player_count].compact.uniq.join("-"))
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
      %i[
        child
        party
        war

        dexterity
        digital_hybrid
        escaperoom_games
        realtime
        traitor
        werewolf
      ].any? { send("#{it}?") }
    end

    def escaperoom_games?
      [
        "EXIT",
        "Deckscape",
        "Rory's Story Cubes",
        "Unlock!",
      ].any? { name.start_with?("#{_1}:") }
    end
  end

  def key
    @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
  end
end
