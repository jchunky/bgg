# frozen_string_literal: true

module Presenters
  class GamesPage
    include Services::ViewHelpers

    def initialize(games)
      @games = games
    end

    def render
      template = File.read("views/bgg.erb")
      ERB.new(template).result(binding)
    end
  end
end
