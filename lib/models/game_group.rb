# frozen_string_literal: true

module Models
  class GameGroup < Data.define(:key, :abbr)
    ALL = [
      new(:party?, "P"),
      new(:coop?, "C"),
      new(:one_player?, "1"),
      new(:two_player?, "2"),
      new(:competitive?, ""),
    ].freeze

    def self.for(game)
      ALL.find { game.send(it.key) }
    end
  end
end
