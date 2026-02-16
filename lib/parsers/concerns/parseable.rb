module Parsers
  module Concerns
    module Parseable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def parse(data)
          new(data).to_game
        rescue ArgumentError, NoMethodError, TypeError
          nil
        end
      end
    end
  end
end
