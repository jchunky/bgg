module Models
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
        @categories ||= Config::Downloaders::CATEGORIES.map(&:prefix).select { send(:"#{_1}?") }
      end

      def subdomains
        @subdomains ||= Config::Downloaders::SUBDOMAINS.map(&:prefix).select { send(:"#{_1}?") }.join(", ")
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
        Models::Game.new(attributes.merge(other.attributes)) { |_, a, b| null?(a) ? b : a }
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

        Config::GameLists.banned_categories.any? { send("#{_1}?") }
      end

      def min_player_count
        return 1 if one_player_game_1?
        return 1 if one_player_game_2?

        super
      end
    end

    concerning :Customize do
      def keep?
        Config::GameLists.keep.include?(name)
      end

      def banned_game?
        Config::GameLists.banned_games.include?(name)
      end

      def banned_series?
        Config::GameLists.banned_series.any? { name.start_with?(_1) }
      end

      def b2go?
        b2go == true || Config::GameLists.b2go_overrides.include?(name)
      end

      def ccc?
        super || Config::GameLists.ccc_overrides.include?(name)
      end

      def weight
        Config::GameLists.weight_overrides.fetch(name, super)
      end

      def child?
        super || Config::GameLists.child_overrides.include?(name)
      end

      def skirmish?
        Config::GameLists.skirmish_games.include?(name)
      end
    end

    def key
      @key ||= name.to_s.downcase.gsub(/[^\w\s]/, "").squish
    end

    concerning :Display do
      def displayable?
        return false unless weight.round(1) <= 2.2
        return false unless !played?
        return false unless b2go? || snakes? || learned?
        return true if learned?
        return true if keep?
        return false unless !campaign?
        return false unless !banned?
        return false unless min_player_count == 1

        true
      end
    end
  end
end
