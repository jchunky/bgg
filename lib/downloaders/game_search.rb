module Downloaders
  class GameSearch < Struct.new(:listid, :prefix, :search_criteria, keyword_init: true)
    def games
      content_for_pages(&method(:games_for_page))
        .uniq(&:key)
        .each.with_index do |game, i|
          game.send("#{prefix}_rank=", i + 1)
        end
        .reject { |g| g.rank.zero? }
    end

    private

    def content_for_pages(&block)
      (1..).each.with_object([]) do |page, result|
        games = block.call(page)
        return result if games.none? { |g| g.rank.positive? }
        result.concat(games)
      end
    end

    def games_for_page(page)
      url = url_for_page(page)
      doc = Utils.fetch_html_data(url)
      games_for_doc(doc, page)
    end

    def url_for_page(page)
      "https://boardgamegeek.com/search/boardgame/page/#{page}?advsearch=1&#{search_criteria}"
    end

    def games_for_doc(doc, page)
      rows(doc).map(&method(:build_game))
    rescue StandardError
      []
    end

    def rows(doc)
      doc
        .css(".collection_table")[0]
        .css("tr")
        .select { |row| row.css("td")[4] }
    end

    def build_game(row)
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
        rank: (a1["name"].to_i rescue 0)
      )
    end
  end
end
