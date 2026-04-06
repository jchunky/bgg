# frozen_string_literal: true

module Presenters
  class GameRow
    include Services::ViewHelpers

    THRESHOLDS = {
      year: (...(Time.now.year - 5)),
      weight: 1...3,
      rank: 1...500,
      rating: 7..,
      player_count: 1..2,
      playtime: 1...60,
      price: 1..30,
      b2go_price: 1..13,
      votes: 1...500,
      votes_rank: 1...500,
      votes_per_year: 1...500,
      votes_per_year_rank: 1...500,
    }.freeze

    delegate :name,
             :href,
             :learned?,
             :played?,
             :banned?,
             :formatted_group,
             :subdomains,
             :category_label,
             :bga?,
             :bgp_url,
             :b2go_url,
             to: :@game

    def initialize(game)
      @game = game
    end

    def bad?(field) = !THRESHOLDS[field]&.cover?(bad_value(field))

    def year = int(@game.year)
    def weight = float(@game.weight)
    def votes = int(@game.rating_count)
    def votes_rank = int(@game.rating_count_rank)
    def votes_per_year = int(@game.votes_per_year)
    def votes_per_year_rank = int(@game.votes_per_year_rank)
    def rank = int(@game.rank)
    def rating = float(@game.rating)
    def playtime = int(@game.max_playtime)
    def price = int(@game.price)
    def b2go_price = int(@game.b2go_price)

    def player_count
      @game.player_count.unknown? ? "" : @game.player_count.to_s
    end

    private

    def bad_value(field)
      case field
      when :player_count then @game.player_count.min
      when :rating then @game.rating&.round(1)
      when :weight then @game.weight&.round(1)
      when :votes, :votes_rank then @game.rating_count_rank
      when :votes_per_year, :votes_per_year_rank then @game.votes_per_year_rank
      else @game.send(field)
      end
    end
  end
end
