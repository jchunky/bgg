# frozen_string_literal: true

module Services
  module ViewHelpers
    def int(value)
      value.to_i.zero? ? "" : value
    end

    def float(value, decimals: 1)
      value.to_f.zero? ? "" : format("%0.#{decimals}f", value)
    end

    def store_links(game)
      links = game.bgp_store_links
      return "" unless links.is_a?(Hash)

      links.map { |name, url| url ? %(<a href="#{url}">#{name}</a>) : name }.join(", ")
    end
  end
end
