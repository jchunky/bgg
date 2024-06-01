module Downloaders
  class GameFetcher < Struct.new(:game, keyword_init: true)
    def community_min_age
      @community_min_age ||= begin
        doc = Utils.fetch_html_data("https://api.geekdo.com/xmlapi2/thing?id=#{game.key}&stats=1")
        community_age = doc.css('button[uib-tooltip="View poll and results"] span')
        community_age.first&.content.to_i
      end
    end
  end
end
