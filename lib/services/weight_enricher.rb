# frozen_string_literal: true

module Services
  class WeightEnricher
    BASE_URL = "https://boardgamegeek.com/xmlapi2/thing"
    CRAWL_DELAY = 5

    def call(games)
      games
        .select { |g| g.weight.to_f.zero? && g.bgg_id.is_a?(Integer) && g.bgg_id.positive? }
        .each { |g| enrich(g) }
    end

    private

    def enrich(game)
      url = "#{BASE_URL}?id=#{game.bgg_id}&stats=1"
      Utils::HttpFetcher.xml(url, crawl_delay: CRAWL_DELAY) do |doc|
        weight = doc.at_css("averageweight")&.[]("value").to_f
        game.weight = weight if weight.positive?
      end
    end
  end
end
