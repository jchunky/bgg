# frozen_string_literal: true

module Config
  module GameLists
    class << self
      def banned_categories = @banned_categories ||= data["banned_categories"].map(&:to_sym).freeze
      def banned_games = @banned_games ||= data["banned_games"].freeze
      def banned_series = @banned_series ||= data["banned_series"].freeze
      def name_aliases = @name_aliases ||= data["name_aliases"].freeze
      def weight_overrides = @weight_overrides ||= data["weight_overrides"].freeze

      def reset!
        @banned_categories = @banned_games = @banned_series = nil
        @name_aliases = @weight_overrides = @data = nil
      end

      private

      def data = @data ||= YAML.load_file("data/game_lists.yml")
    end
  end
end
