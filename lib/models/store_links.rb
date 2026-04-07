# frozen_string_literal: true

module Models
  StoreLinks = Data.define(:links) do
    EMPTY = new(links: {}).freeze # rubocop:disable Lint/ConstantDefinitionInBlock

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
