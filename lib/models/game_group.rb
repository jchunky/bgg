# frozen_string_literal: true

module Models
  GameGroup = Data.define(:key, :name, :abbr) do
    ALL = [
      new(:party?,      "party",    "P"),
      new(:coop?,       "coop",     "C"),
      new(:one_player?, "1-player", "1"),
      new(:two_player?, "2-player", "2"),
    ].freeze

    COMPETITIVE = new(nil, "competitive", nil).freeze

    def self.for(game)
      ALL.find { game.send(it.key) } || COMPETITIVE
    end

    def to_s = name
  end
end
