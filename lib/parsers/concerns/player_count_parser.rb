module Parsers
  module Concerns
    module PlayerCountParser
      private

      def parse_player_count(player_count)
        return [nil, nil] if player_count.nil? || player_count.empty?

        if player_count.include?("-")
          player_count.split("-").map(&:to_i)
        else
          count = player_count.to_i
          [count, count]
        end
      end
    end
  end
end
