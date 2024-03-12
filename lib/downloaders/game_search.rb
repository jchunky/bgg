module Downloaders
  class GameSearch < Struct.new(:listid, :prefix, :search_criteria, keyword_init: true)
    def games
      (1..10)
        .flat_map(&method(:games_for_page))
        .compact
        .uniq(&:key)
    end

    private

    def games_for_page(page)
      url = url_for_page(page)
      doc = Utils.fetch_html_data(url)
      games_for_doc(doc, page)
    end

    def url_for_page(page)
      "https://boardgamegeek.com/search/boardgame/page/#{page}?advsearch=1&#{search_criteria}"
    end

    def games_for_doc(doc, page)
      doc.css(".collection_table")[0].css("tr")
        .select { |row| row.css("td")[4] }
        .map.with_index do |row, i|
          rank, _, title, _, rating, rating_count = row.css("td")
          anchor = title.css("a")[0]
          name = anchor.content

          Game.new(
            href: anchor["href"],
            name:,
            rating: rating.content.to_f,
            rating_count: rating_count.content.to_i,
            year: (title.css("span")[0].content[1..-2].to_i rescue 0),
            rank: (rank.css("a")[0]["name"].to_i rescue 0),
            "#{prefix}_rank": ((page - 1) * 100) + i + 1
          )
        end
    rescue StandardError
      []
    end
  end
end
