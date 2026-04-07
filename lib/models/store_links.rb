# frozen_string_literal: true

module Models
  class StoreLinks < Data.define(:links)
    EMPTY = new(links: {}).freeze

    def best_url
      links.values.compact.first
    end

    def merge(other)
      self.class.new(links: links.merge(other.links))
    end

    def empty?
      links.empty?
    end
  end
end
