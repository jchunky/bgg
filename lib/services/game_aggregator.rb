module Services
  class GameAggregator
    def call
      Config::Downloaders::DOWNLOADERS
        .flat_map(&:games)
        .group_by(&:key)
        .transform_values { |games| games.reduce { |acc, game| game.merge(acc) } }
        .values
        .select { |game| game.rank.positive? }
        .sort_by(&:rank)
        .uniq(&:name)
    end
  end
end
