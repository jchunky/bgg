# frozen_string_literal: true

module Services
  class GameAggregator
    def call
      merge_groups(group_games)
        .select { |game| game.rank.positive? }
        .sort_by(&:rank)
        .uniq(&:name)
    end

    private

    def all_games
      Config::Sources::DOWNLOADERS.flat_map(&:games)
    end

    def group_games
      by_id = {}
      by_key = {}

      all_games.each do |game|
        if game.valid_bgg_id?
          (by_id[game.bgg_id] ||= []) << game
        else
          (by_key[game.key] ||= []) << game
        end
      end

      fold_fuzzy_into_id_groups(by_id, by_key)

      by_id.values + by_key.values
    end

    def fold_fuzzy_into_id_groups(by_id, by_key)
      id_keys = by_id.each_value.with_object({}) do |games, map|
        games.each { |g| map[g.key] = games }
      end

      by_key.keys.each do |key|
        next unless id_keys.key?(key)

        id_keys[key].concat(by_key.delete(key))
      end
    end

    def merge_groups(groups)
      groups.map do |games|
        games.reduce { |acc, game| game.merge(acc) }
      end
    end
  end
end
