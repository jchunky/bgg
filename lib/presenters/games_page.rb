# frozen_string_literal: true

module Presenters
  class GamesPage
    def initialize(games)
      @rows = games.map { Presenters::GameRow.new(it) }
    end

    def game_count = @rows.size

    def render
      template = File.read("views/bgg.erb")
      ERB.new(template).result(binding)
    end
  end
end
