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
          c1, _, c3, _, c5, c6 = row.css("td")
          a1 = c1.css("a")[0]
          a3 = c3.css("a")[0]
          span3 = c3.css("span")[0]

          Game.new(
            href: a3["href"],
            name: a3.content,
            rating: c5.content.to_f,
            rating_count: c6.content.to_i,
            year: (span3.content[1..-2].to_i rescue 0),
            rank: (a1["name"].to_i rescue 0),
            "#{prefix}_rank": ((page - 1) * 100) + i + 1
          )
        end
    rescue StandardError
      []
    end
  end
end
