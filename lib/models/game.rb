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
      def category_label = @category_label ||= categories.sort.join(", ")
      def categories = @categories ||= Config::Downloaders::CATEGORIES.select(&:display).map(&:prefix).select { send(:"#{it}?") }
      def subdomains = @subdomains ||= Config::Downloaders::SUBDOMAINS.map(&:prefix).select { send(:"#{it}?") }.map { it[0].upcase }.join
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
        @key ||= Models::NormalizedName.from(resolved_name)
      end

      def resolved_name
        Config::GameLists.name_aliases.fetch(name, name)
      end

      private

      def null?(value)
        !value || (value.respond_to?(:zero?) && value.zero?)
      end
    end

    concerning :PlayerCount do
      def player_count
        @player_count ||= Models::PlayerCount.new(
          min: minplayers.to_i,
          max: maxplayers.to_i,
        )
      end
    end

    concerning :GameData do
      def competitive? = group == "competitive"
      def crowdfunded? = kickstarter? || gamefound? || backerkit?
      def learned? = self.class.learned.include?(name)
      def one_player? = player_count.one_player?
      def play_rank? = (play_rank > 0)
      def played? = self.class.played.include?(name)
      def price = bgp_price.to_f.round
      def soloable? = player_count.soloable?(coop: coop?)
      def two_player? = player_count.two_player?

      def max_playtime = maxplaytime.to_i

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
      def b2go? = b2go == true
      def b2go_url = b2go_id ? "https://www.boardgame2go.com/login/?guest=true&detail=#{b2go_id}" : nil
      def bgp? = bgp == true
      def bgp_url = bgp_store_links.is_a?(Hash) ? bgp_store_links.values.compact.first : nil
      def banned? = banned_game? || banned_series? || banned_categories?
      def banned_game? = Config::GameLists.banned_games.include?(name)
      def banned_series? = Config::GameLists.banned_series.any? { name.start_with?(it) }
      def banned_categories? = Config::GameLists.banned_categories.any? { send("#{it}?") }
      def weight = Config::GameLists.weight_overrides.fetch(name, super)
    end

    concerning :Display do
      def displayable?
        return false if weight.round(1) > 2.2
        return false if played?
        return false unless b2go?
        return true if learned?
        # return false if campaign?
        return false if banned?
        return false if player_count.min != 1
        # return false unless soloable?
        # return false if price == 0

        true
      end
    end
  end
end
