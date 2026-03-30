# frozen_string_literal: true

module Config
  module GameLists
    class << self
      def banned_categories = data["banned_categories"].map(&:to_sym)
      def banned_games = data["banned_games"]
      def banned_series = data["banned_series"]
      def name_aliases = data["name_aliases"]
      def weight_overrides = data["weight_overrides"]

      private

      def data = @data ||= YAML.load_file("data/game_lists.yml")
    end
  end
end
