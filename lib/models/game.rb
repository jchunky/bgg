# frozen_string_literal: true

module Models
  class Game
    class << self
      def learned = @learned ||= read_list("learned.txt").freeze
      def played = @played ||= read_list("played_games.txt").freeze

      def reset!
        @learned = @played = nil
      end

      private

      def read_list(filename) = File.read("./data/#{filename}").split("\n").reject(&:blank?)
    end

    attr_reader :attributes

    def initialize(args)
      @attributes = Hash.new(0).merge(args)
    end

    concerning :Categories do
      def category_label = @category_label ||= categories.sort.join(", ")
      def categories = @categories ||= Config::Downloaders::CATEGORIES.select(&:display).map(&:prefix).select { ranked_in?(it) }
      def subdomains = @subdomains ||= Config::Downloaders::SUBDOMAINS.map(&:prefix).select { ranked_in?(it) }.map { it[0].upcase }.join
    end

    concerning :Attributes do
      def ranked_in?(category)
        !null?(send(:"#{category}_rank"))
      end

      def method_missing(method_name, *args)
        attribute_name = method_name.to_s.chomp("=").chomp("?").to_sym
        if method_name.to_s.end_with?("=")
          attributes[attribute_name] = args.first
        elsif method_name.to_s.end_with?("?")
          ranked_in?(attribute_name)
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
      def crowdfunded? = kickstarter? || gamefound? || backerkit?
      def learned? = self.class.learned.include?(name)
      def play_rank? = (play_rank > 0)
      def played? = self.class.played.include?(name)
      def soloable? = player_count.soloable?(coop: coop?)

      def one_player? = player_count.one_player?
      def two_player? = player_count.two_player?
      def competitive? = player_count.competitive?

      def price = bgp_price.to_f.round
      def max_playtime = maxplaytime.to_i
      def formatted_group = game_group.abbr
      def game_group = @game_group ||= Models::GameGroup.for(self)

      def votes_per_year
        days_published = ((Time.now.year - year.to_i) * 365) + Time.now.yday
        years_published = days_published.to_f / 365

        (rating_count / years_published).round
      end
    end

    concerning :Customize do
      def displayable? = Services::GameFilter.new(self).displayable?

      def b2go? = b2go == true
      def b2go_url = b2go_id ? "https://www.boardgame2go.com/login/?guest=true&detail=#{b2go_id}" : nil
      def bgp? = bgp == true
      def bgp_url = bgp_store_links.is_a?(Hash) ? bgp_store_links.values.compact.first : nil

      def banned? = banned_game? || banned_series? || banned_categories?
      def banned_game? = Config::GameLists.banned_games.include?(name)
      def banned_series? = Config::GameLists.banned_series.any? { name.start_with?(it) }
      def banned_categories? = Config::GameLists.banned_categories.any? { ranked_in?(it) }

      def weight = Config::GameLists.weight_overrides.fetch(name, super)
    end
  end
end
