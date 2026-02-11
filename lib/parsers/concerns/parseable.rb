module Parsers
  module Concerns
    module Parseable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def parse(data)
          new(data).to_game
        rescue StandardError
          nil
        end
      end
    end
  end
end
