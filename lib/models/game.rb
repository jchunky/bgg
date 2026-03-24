# frozen_string_literal: true

module Models
  class Game
    class << self
      def learned = @learned ||= read_list("learned.txt")
      def played = @played ||= read_list("played_games.txt")

      private

      def read_list(filename) = File.read("./data/#{filename}").split("\n").reject(&:blank?)
    end

    attr_reader :attributes

    def initialize(args)
      @attributes = Hash.new(0).merge(args)
    end

    concerning :Categories do
      def category_label = @category_label ||= [*categories, *source_labels].compact.sort.join(", ")
      def categories = @categories ||= Config::Downloaders::CATEGORIES.map(&:prefix).select { send(:"#{it}?") }
      def subdomains = @subdomains ||= Config::Downloaders::SUBDOMAINS.map(&:prefix).select { send(:"#{it}?") }.join(", ")

      private

      def source_labels
        [
          (:b2go if b2go?),
          (:bgp if bgp?),
          (:ccc if ccc?),
        ]
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

      def respond_to_missing?(_method_name, _include_private = false)
        true
      end

      def merge(other)
        merged = attributes.merge(other.attributes) { |_, a, b| null?(b) ? a : b }
        Models::Game.new(merged)
      end

      def key
        @key ||= name.to_s
          .unicode_normalize(:nfkd).gsub(/[\u0300-\u036f]/, "")
          .downcase
          .gsub("&", " and ")
          .gsub(/['\u2019]s\b/, "")
          .gsub(/[^\w\s]/, "")
          .gsub(/\b(1st|first)\b/, "1")
          .gsub(/\b(2nd|second)\b/, "2")
          .gsub(/\b(3rd|third)\b/, "3")
          .gsub(/\b(4th|fourth)\b/, "4")
          .gsub(/\b(5th|fifth)\b/, "5")
          .gsub(/\b(6th|sixth)\b/, "6")
          .gsub(/\bedition\b/, "")
          .gsub(/\b(the|a)\b/, "")
          .squish
      end

      private

      def null?(value)
        !value || (value.respond_to?(:zero?) && value.zero?)
      end
    end

    concerning :PlayerCount do
      def player_count
        return @player_count if defined?(@player_count)

        @player_count = calculate_player_count
      end

      def min_player_count
        @min_player_count ||= (1..12).find { |count| send(:"player_#{count}?") } || 0
      end

      def max_player_count
        @max_player_count ||= (1..12).to_a.reverse.find { |count| send(:"player_#{count}?") } || 0
      end

      private

      def calculate_player_count
        return nil if min_player_count.zero?

        [min_player_count, max_player_count].compact.uniq.join("-")
      end
    end

    concerning :GameData do
      def competitive? = group == "competitive"
      def crowdfunded? = kickstarter? || gamefound? || backerkit?
      def learned? = self.class.learned.include?(name)
      def normalized_price = bgp_price.to_f.round
      def one_player? = max_player_count == 1
      def play_rank? = (play_rank > 0)
      def played? = self.class.played.include?(name)
      def player_count_range = (min_player_count..max_player_count)
      def soloable? = max_player_count == 1 || (coop? && min_player_count == 1)
      def two_player? = max_player_count == 2

      def max_playtime
        @max_playtime ||= (15..360).step(15).find { |time| send(:"playtime_#{time}?") } || 0
      end

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
    end

    concerning :Customize do
      def b2go? = b2go == true || Config::GameLists.b2go_overrides.include?(name)
      def bgp? = bgp == true
      def banned? = banned_game? || banned_series? || Config::GameLists.banned_categories.any? { send("#{it}?") }
      def banned_game? = Config::GameLists.banned_games.include?(name)
      def banned_series? = Config::GameLists.banned_series.any? { name.start_with?(it) }
      def ccc? = super || Config::GameLists.ccc_overrides.include?(name)
      def child? = super || Config::GameLists.child_overrides.include?(name)
      def keep? = Config::GameLists.keep.include?(name)
      def skirmish? = Config::GameLists.skirmish_games.include?(name)
    end

    concerning :Display do
      def displayable?
        return false if weight.round(1) > 2.2
        return false if played?
        return false unless b2go?
        return true if learned?
        return true if keep?
        return false if campaign?
        return false if banned?
        return false unless min_player_count == 1

        true
      end
    end
  end
end
