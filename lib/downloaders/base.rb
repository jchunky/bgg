module Downloaders
  class Base
    def prefix
      raise NotImplementedError, "#{self.class} must implement #prefix"
    end

    def listid
      raise NotImplementedError, "#{self.class} must implement #listid"
    end

    def games
      raise NotImplementedError, "#{self.class} must implement #games"
    end
  end
end
