# frozen_string_literal: true

module Models
  GameGroup = Data.define(:key, :abbr) do
    ALL = [ # rubocop:disable Lint/ConstantDefinitionInBlock
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
