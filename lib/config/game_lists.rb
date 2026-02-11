module Config
  module GameLists
    class << self
      def b2go_overrides = data["b2go_overrides"]
      def banned_categories = data["banned_categories"].map(&:to_sym)
      def banned_games = data["banned_games"]
      def banned_series = data["banned_series"]
      def ccc_overrides = data["ccc_overrides"]
      def child_overrides = data["child_overrides"]
      def keep = data["keep"]
      def skirmish_games = data["skirmish_games"]
      def weight_overrides = data["weight_overrides"]

      private

      def data = @data ||= YAML.load_file("config/game_lists.yml")
    end
  end
end
