module Config
  module GameLists
    def self.data
      @data ||= YAML.load_file("config/game_lists.yml")
    end

    def self.keep
      data["keep"]
    end

    def self.banned_games
      data["banned_games"]
    end

    def self.banned_series
      data["banned_series"]
    end

    def self.banned_categories
      data["banned_categories"].map(&:to_sym)
    end

    def self.b2go_overrides
      data["b2go_overrides"]
    end

    def self.ccc_overrides
      data["ccc_overrides"]
    end

    def self.child_overrides
      data["child_overrides"]
    end

    def self.skirmish_games
      data["skirmish_games"]
    end

    def self.weight_overrides
      data["weight_overrides"]
    end
  end
end
