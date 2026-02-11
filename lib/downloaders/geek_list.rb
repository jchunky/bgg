module Downloaders
  class GeekList < Struct.new(:listid, :prefix, :reverse_rank)
    def games
      @games ||= begin
        result = (1..8).flat_map { games_for_page(_1) }.compact.uniq(&:key)
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
      doc["data"].map do |record|
        Models::Game.new(
          href: record["item"]["href"],
          name: record["item"]["name"],
          rating: record["stats"]["average"].to_f,
          rank: record["stats"]["rank"].to_i
        )
      end
    end
  end
end
