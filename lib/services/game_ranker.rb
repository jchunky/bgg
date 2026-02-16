module Services
  class GameRanker
    def call(games)
      assign_ranks(games, :votes_per_year, :votes_per_year_rank)
      assign_ranks(games, :rating_count, :rating_count_rank)
      games
    end

    private

    def assign_ranks(games, sort_attr, rank_attr)
      games
        .sort_by { |g| -g.send(sort_attr) }
        .each.with_index(1) { |g, i| g.send(:"#{rank_attr}=", i) }
    end
  end
end
