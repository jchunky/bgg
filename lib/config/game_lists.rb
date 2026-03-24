# frozen_string_literal: true

module Config
  module GameLists
    class << self
      def b2go_overrides = data["b2go_overrides"]
      def banned_categories = data["banned_categories"].map(&:to_sym)
      def banned_games = data["banned_games"]
      def banned_series = data["banned_series"]
      def child_overrides = data["child_overrides"]
      def keep = data["keep"]
      def skirmish_games = data["skirmish_games"]

      private

      def data = @data ||= YAML.load_file("data/game_lists.yml")
    end
  end
end
