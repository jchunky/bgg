module Downloaders
  class GeekList < Struct.new(:listid, :prefix, :reverse_rank)
    def games
      @games ||= begin
        result = (1..8).flat_map { games_for_page(it) }.compact.uniq(&:key)
        result = result.reverse if reverse_rank
        result.each.with_index(1) do |game, i|
          game.send(:"#{prefix}_rank=", i)
        end
      end
    end

    private

    def games_for_page(page)
      url = url_for_page(page)
      Utils::HttpFetcher.fetch_json_data(url) do |doc|
        games_for_doc(doc, page)
      end
    end

    def url_for_page(page)
      "https://api.geekdo.com/api/listitems?listid=#{listid}&page=#{page}"
    end

    def games_for_doc(doc, _page)
      doc.fetch("data", []).map do |record|
        Models::Game.new(
          href: record.dig("item", "href"),
          name: record.dig("item", "name"),
          rating: record.dig("stats", "average").to_f,
          rank: record.dig("stats", "rank").to_i
        )
      end
    end
  end
end
