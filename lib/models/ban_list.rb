# frozen_string_literal: true

module Models
  class BanList
    def initialize(name:, ranked_categories:)
      @name = name
      @ranked_categories = ranked_categories
    end

    def banned?
      banned_game? || banned_series? || banned_category?
    end

    private

    def banned_game?
      Config::GameLists.banned_games.include?(@name)
    end

    def banned_series?
      Config::GameLists.banned_series.any? { @name.start_with?(it) }
    end

    def banned_category?
      Config::GameLists.banned_categories.any? { @ranked_categories.include?(it) }
    end
  end
end
