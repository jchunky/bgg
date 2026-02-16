module Services
  class GameAggregator
    def call
      Config::Downloaders::DOWNLOADERS
        .flat_map(&:games)
        .group_by(&:key)
        .transform_values { |games| games.reduce { |game1, game2| game2.merge(game1) } }
        .values
        .select { |game| game.rank.positive? }
        .sort_by(&:rank)
        .uniq(&:name)
    end
  end
end
